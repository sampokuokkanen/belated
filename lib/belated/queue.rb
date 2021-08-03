require 'belated/job'

class Belated
  class Queue
    attr_accessor :future_jobs

    def initialize(queue: Thread::Queue.new, future_jobs: [])
      @queue = queue
      self.future_jobs = future_jobs
    end

    def push(job, at: nil)
      if at.nil?
        @queue.push(job)
      else
        @future_jobs << Job.new(job, at)
      end
    end

    def pop
      @queue.pop
    end

    def clear
      @queue.clear
      self.future_jobs = []
    end

    def empty?
      @queue.empty?
    end

    def length
      @queue.length
    end
  end
end
