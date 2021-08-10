require 'securerandom'
require_relative 'logging'

class Belated
  class JobWrapper
    include Logging
    attr_accessor :retries, :max_retries, :id, :job, :at

    def initialize(job:, max_retries: 5, at: nil)
      self.retries = 0
      self.max_retries = max_retries
      self.id = SecureRandom.uuid
      self.job = job
      self.at = at
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
        self.retries += 1
        unless retries > max_retries
          self.at = Time.now.utc + (retries.next ** 4)
          log "Job #{id} failed, retrying at #{at}"
          Belated.job_list.push(self)
        end
        "Error while executing job, #{e.inspect}"
      end
    end
    # rubocop:enable Lint/RescueException
  end
end
