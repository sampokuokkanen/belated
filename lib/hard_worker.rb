# frozen_string_literal: true

require_relative 'hard_worker/version'
require_relative 'hard_worker/worker'
require 'byebug'
require 'drb'

# HardWorker is a pure Ruby job backend.
# It has limited functionality, as it only accepts
# jobs as procs, but that might make it useful if you don't
# need anything as big as Redis.
# Loses all jobs if restarted.
class HardWorker
  URI = 'druby://localhost:8788'
  @@queue = Queue.new

  def initialize(workers: 1, connect: false)
    @worker_list = []
    workers.times do |_i|
      @worker_list << Thread.new { Worker.new }
    end
    return unless connect

    DRb.start_service(URI, @@queue)
    puts "listening on #{URI}"
    DRb.thread.join
  end

  def stop_workers
    @worker_list.each do |worker|
      Thread.kill(worker)
    end
  end

  def job_list
    @@queue
  end

  def self.fetch_job
    @@queue.pop
  end

  class Error < StandardError; end
end
