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

        break if job.is_a?(Symbol)

        log "Worker #{@number} got job: #{job.inspect}"
        log job.perform
      rescue RangeError => e
        log e
      end
    end
  end
end
