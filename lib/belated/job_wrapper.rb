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
    attr_accessor :retries, :max_retries, :id, :job, :at, :completed, :proc_klass

    def initialize(job:, max_retries: 5, at: nil)
      self.retries = 0
      self.max_retries = max_retries
      self.id = SecureRandom.uuid
      self.job = job
      self.at = at
      self.completed = false
      self.proc_klass = job.instance_of?(Proc)
    end

    def <=>(other)
      at <=> other.at
    end

    # rubocop:disable Lint/RescueException
    def perform
      execute
    rescue Exception => e
      case e.class
      when Interrupt, SignalException
        raise e
      else
        retry_job
        "Error while executing job, #{e.inspect}. Retry #{retries} of #{max_retries}"
      end
    end

    # rubocop:enable Lint/RescueException
    def execute
      resp = if job.respond_to?(:call)
               job.call
             elsif job.respond_to?(:arguments)
               job.perform(*job.arguments)
             else
               job.perform
             end
      self.completed = true
      resp
    end

    def retry_job
      self.retries += 1
      return if retries > max_retries

      self.at = Time.now + (retries.next**4)
      log "Job #{id} failed, retrying at #{at}"
      Belated.job_list.push(self)
    end
  end
end
