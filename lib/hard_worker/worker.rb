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

        call_job(job)
        puts 'fetching jobs...'
      end
    end

    def call_job(job)
      if job.instance_of?(Proc)
        pp job.call
      else
        pp job&.perform
      end
    end
  end
end
