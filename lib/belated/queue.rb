# frozen_string_literal: true

require 'belated/job'
require 'belated/logging'
require 'belated/job_wrapper'
require 'sorted_set'

class Belated
  # Job queues that Belated uses.
  # queue is the jobs that are currenly
  # waiting for a worker to start working on them.
  # future_jobs is a SortedSet of jobs that are going
  # to be added to queue at some point in the future.
  class Queue
    include Logging
    attr_accessor :future_jobs

    FILE_NAME = 'belated_dump'

    def initialize(queue: Thread::Queue.new, future_jobs: SortedSet.new)
      @queue = queue
      @mutex = Mutex.new
      self.future_jobs = future_jobs
    end

    def push(job)
      if job.is_a?(Symbol) || job.at.nil? ||
         job.at <= Time.now.to_f
        @queue.push(job)
      else
        @mutex.synchronize do
          @future_jobs << job
        end
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

    def load_jobs
      log "reloading... if file exists #{File.exist?(FILE_NAME)}"
      return unless File.exist?(FILE_NAME)

      jobs = YAML.load(File.binread(FILE_NAME))
      jobs.each do |job|
        if job.at && job.at > Time.now.to_f
          future_jobs.push(job)
        else
          @queue.push(job)
        end
      end
      File.delete(FILE_NAME)
    end

    def save_jobs
      class_array = []
      @queue.length.times do |_i|
        unless proc_or_shutdown?(klass = @queue.pop)
          class_array << klass
        end
      end
      future_jobs.each do |_job|
        unless proc_or_shutdown?(klass = future_jobs.pop)
          class_array << klass
        end
      end

      pp File.open(FILE_NAME, 'wb') { |f| f.write(YAML.dump(class_array)) }
    end

    def connected?
      true
    end

    private

    def proc_or_shutdown?(job)
      job.is_a?(Symbol) || job.job.instance_of?(Proc)
    end
  end
end
