require_relative 'logging'
class Belated
  # The worker class that actually gets the jobs from the queue
  # and calls them. Expects the jobs to be procs.
  class Worker
    include Logging

    def initialize
      start_working
    end

    def start_working
      loop do
        next unless (job = Belated.fetch_job)

        break if job == :shutdown

        log call_job(job)
        log 'fetching jobs...'
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
