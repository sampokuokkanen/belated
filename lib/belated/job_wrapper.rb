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
    attr_accessor :retries, :max_retries, :id, :job, :at

    def initialize(job:, max_retries: 5, at: nil)
      self.retries = 0
      self.max_retries = max_retries
      self.id = SecureRandom.uuid
      self.job = job
      self.at = at
    end

    def <=>(other)
      at <=> other.at
    end

    # rubocop:disable Lint/RescueException
    def perform
      if job.respond_to?(:call)
        job.call
      else
        job.perform
      end
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

    def retry_job
      self.retries += 1
      return if retries > max_retries

      self.at = Time.now.utc + (retries.next**4)
      log "Job #{id} failed, retrying at #{at}"
      Belated.job_list.push(self)
    end
  end
end
