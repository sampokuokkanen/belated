# frozen_string_literal: true

require_relative 'hard_worker/version'
require_relative 'hard_worker/worker'
require 'drb'
require 'yaml'

# HardWorker is a pure Ruby job backend.
# It has limited functionality, as it only accepts
# jobs as procs, but that might make it useful if you don't
# need anything as big as Redis.
# Loses all jobs if restarted.
class HardWorker
  URI = 'druby://localhost:8788'
  FILE_NAME = 'hard_worker_dump'
  @@queue = Queue.new

  def initialize(workers: 1, connect: false)
    load_jobs
    @worker_list = []
    workers.times do |_i|
      @worker_list << Thread.new { Worker.new }
    end
    return unless connect

    DRb.start_service(URI, @@queue)
    puts "listening on #{URI}"
    DRb.thread.join
  end

  def load_jobs
    jobs = YAML.load(File.binread(FILE_NAME))
    jobs.each do |job|
      @@queue.push(job)
    end
  rescue StandardError
    # do nothing
  end

  def stop_workers
    @worker_list.each do |worker|
      Thread.kill(worker)
    end
    class_array = []
    @@queue.size.times do |_i|
      next if (klass_or_proc = @@queue.pop).instance_of?(Proc)

      class_array << klass_or_proc
    end
    File.open(FILE_NAME, 'wb') { |f| f.write(YAML.dump(class_array)) }
  end

  def reset_queue!
    @@queue = Queue.new
  end

  def job_list
    @@queue
  end

  def self.fetch_job
    @@queue.pop
  end

  class Error < StandardError; end
end
