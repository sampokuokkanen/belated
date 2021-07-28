class Belated
  # The worker class that actually gets the jobs from the queue
  # and calls them. Expects the jobs to be procs.
  class Worker
    
    def initialize
      start_working
    end

    def start_working
      loop do
        job = Belated.fetch_job
        next unless job

        call_job(job)
        puts 'fetching jobs...'
      end
    end

    def call_job(job)
      if job.respond_to?(:call)
        Belated.config.logger job.call
      else
        Belated.config.loggerr job.perform
      end
    rescue StandardError => e
      Belated.config.logger e.inspect
    end
  end
end
