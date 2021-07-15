class HardWorker
  # The worker class that actually gets the jobs from the queue
  # and calls them. Expects the jobs to be procs.
  class Worker
    def initialize
      start_working
    end

    def start_working
      loop do
        pp HardWorker.fetch_job.call
        puts 'fetching jobs...'
      end
    end
  end
end
