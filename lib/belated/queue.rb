# frozen_string_literal: true

require 'belated/logging'
require 'belated/job_wrapper'
require 'sorted_set'
require 'pstore'
class Belated
  # Job queues that Belated uses.
  # queue is the jobs that are currenly
  # waiting for a worker to start working on them.
  # future_jobs is a SortedSet of jobs that are going
  # to be added to queue at some point in the future.
  class Queue
    include Logging
    attr_accessor :future_jobs, :future_jobs_db

    FILE_NAME = 'belated_dump'

    def initialize(queue: Thread::Queue.new, future_jobs: SortedSet.new)
      @queue = queue
      @mutex = Mutex.new
      self.future_jobs = future_jobs
      self.future_jobs_db = PStore.new("future_jobs_#{Belated.environment}.pstore", true) # pass true for thread safety
    end

    def enqueue_future_jobs
      loop do
        job = future_jobs.min
        if job.nil?
          sleep Belated.heartbeat
          next
        end
        if job.at <= Time.now.to_f
          delete_job(job)
          push(job)
        end
      rescue DRb::DRbConnError
        error 'DRb connection error!!!!!!'
        log stats
      end
    end

    def push(job)
      if job.is_a?(Symbol) || job.at.nil? ||
         job.at <= Time.now.to_f
        @queue.push(job)
      else
        @mutex.synchronize do
          @future_jobs << job
          insert_into_future_jobs_db(job) unless job.proc_klass
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
      future_jobs_db.transaction(true) do
        future_jobs_db.roots.each do |id|
          future_jobs << future_jobs_db[id]
        end
      end
      return unless File.exist?(FILE_NAME)

      jobs = YAML.load(File.binread(FILE_NAME))
      jobs.each do |job|
        @queue.push(job)
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
      pp File.open(FILE_NAME, 'wb') { |f| f.write(YAML.dump(class_array)) }
    end

    def connected?
      true
    end

    def find(job_id)
      job = nil
      future_jobs_db.transaction(true) do
        job = future_jobs_db[job_id]
      end
      job = future_jobs.find { |j| j.id == job_id } if job.nil?
      job
    end

    def delete_job(job)
      log "Deleting #{future_jobs.delete(job)} from future jobs"
      future_jobs_db.transaction do
        future_jobs_db.delete(job.id)
      end
    end

    private

    def proc_or_shutdown?(job)
      job.is_a?(Symbol) || job.job.instance_of?(Proc)
    end

    def insert_into_future_jobs_db(job)
      future_jobs_db.transaction do
        future_jobs_db[job.id] = job
      end
    end
  end
end
