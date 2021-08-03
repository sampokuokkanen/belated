require_relative 'logging'
class Belated
  # The worker class that actually gets the jobs from the queue
  # and calls them. Expects the jobs to be procs or
  # classes that have a perform method.
  class Worker
    include Logging

    def initialize(number: 1)
      @number = number
      start_working
    end

    def start_working
      loop do
        log "Worker #{@number} fetching jobs!"
        next unless (job = Belated.fetch_job)

        break if job == :shutdown

        log call_job(job)
      end
    end

    def call_job(job)
      if job.respond_to?(:call)
        job.call
      else
        job.perform
      end
    rescue StandardError => e
      e.inspect
    end
  end
end
