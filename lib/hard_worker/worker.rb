require_relative "queue"

class HardWorker
  class Worker

    def initialize
      start_working
    end

    def start_working
      while true do
        if job = fetch_job
          job.call
        end
        sleep 1
      end
    end

    def now!(&block)
      block.call
    end

    private

    def fetch_job
      Queue.job_list.shift unless Queue.job_list.empty?
    end
  end
end