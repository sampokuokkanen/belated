class HardWorker
  module Queue
    extend self

    def job_list
      @queue ||= []
    end
  end
end