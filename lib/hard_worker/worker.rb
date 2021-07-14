class HardWorker
  class Worker

    def initialize
      start_working
    end

    def start_working
      while true do
        HardWorker.fetch_job.call
      end
    end
  end
end