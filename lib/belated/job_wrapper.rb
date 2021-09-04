require 'securerandom'
require_relative 'logging'

class Belated
  # JobWrapper is a wrapper for a job. It is responsible for
  # - logging
  # - error handling
  # - job execution
  # - job result handling
  # - job result logging
  # - job retries
  # - job retry delay
  class JobWrapper
    include Comparable
    include Logging
    attr_accessor :retries, :max_retries, :id, :job, :at, :completed, :proc_klass, :error, :active_job

    def initialize(job:, max_retries: 5, at: nil, active_job: false)
      self.retries = 0
      self.max_retries = max_retries
      self.id = job.respond_to?(:job_id) ? job.job_id : SecureRandom.uuid
      self.job = job
      self.at = at
      self.completed = false
      self.proc_klass = job.instance_of?(Proc)
      self.active_job = active_job
    end

    def <=>(other)
      at <=> other.at
    end

    # rubocop:disable Lint/RescueException
    def perform
      resp = execute
      self.completed = true
      resp
    rescue Exception => e
      case e.class
      when Interrupt, SignalException
        raise e
      else
        retry_job(e)
        "Error while executing job #{job.inspect}, #{e.inspect}. Retry #{retries} of #{max_retries}"
      end
    end

    # rubocop:enable Lint/RescueException
    def execute
      if active_job
        ActiveJob::Base.execute job.serialize
      elsif job.respond_to?(:call)
        job.call
      elsif job.respond_to?(:arguments)
        job.perform(*job.arguments)
      else
        job.perform
      end
    end

    def retry_job(error)
      self.retries += 1
      if retries > max_retries
        self.error = error
        return
      end

      seconds_to_retry = $TESTING ? 0.05 : retries.next**4
      self.at = (Time.now + seconds_to_retry).to_f
      log "Job #{id} failed, retrying at #{at}"
      Belated.job_list.push(self)
    end
  end
end
