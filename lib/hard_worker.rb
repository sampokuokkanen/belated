# frozen_string_literal: true

require_relative "hard_worker/version"
require_relative "hard_worker/worker"
require 'byebug'

class HardWorker
  @worker_list

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

  class Error < StandardError; end
end
