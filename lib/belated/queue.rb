# frozen_string_literal: true

require 'belated/job'
require 'belated/logging'
require 'belated/job_wrapper'
class Belated
  class Queue
    include Logging
    attr_accessor :future_jobs

    FILE_NAME = 'belated_dump'

    def initialize(queue: Thread::Queue.new, future_jobs: [])
      @queue = queue
      self.future_jobs = future_jobs
    end

    def push(job)
      if job.at.nil? || job.at <= Time.now.utc
        @queue.push(job)
      else
        @future_jobs << job
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
        if job.at && job.at > Time.now.utc
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

    private

    def proc_or_shutdown?(job)
      job.job.instance_of?(Proc) || job == :shutdown
    end
  end
end
