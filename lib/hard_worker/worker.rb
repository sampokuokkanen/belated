class HardWorker
  # The worker class that actually gets the jobs from the queue
  # and calls them. Expects the jobs to be procs.
  class Worker
    def initialize
      start_working
    end

    def start_working
      loop do
        job = HardWorker.fetch_job
        next unless job

        if job.class == Proc
          pp job.call
        else
          pp job.inspect
          pp job&.perform
        end
        puts 'fetching jobs...'
      end
    end
  end
end
