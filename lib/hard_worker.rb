# frozen_string_literal: true

require_relative "hard_worker/version"
require_relative "hard_worker/worker"
require 'byebug'
require 'thread'

class HardWorker
  @worker_list
  @queue = Queue.new

  def initialize(workers: 1)
    @worker_list = []
    workers.times do |i|
      @worker_list << Thread.new { Worker.new }
    end
  end

  def stop_workers
    @worker_list.each do |worker|
      Thread.kill(worker)
    end
  end

  def self.job_list
    @queue
  end

  def self.fetch_job
    @queue.pop
  end

  class Error < StandardError; end
end
