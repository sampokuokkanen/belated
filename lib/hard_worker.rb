# frozen_string_literal: true

require_relative 'hard_worker/version'
require_relative 'hard_worker/worker'
require 'drb'
require 'yaml'
require 'singleton'
require 'dry-configurable'
require 'hard_worker/client'
require 'hard_worker/rails' if defined?(::Rails::Engine)

# HardWorker is a pure Ruby job backend.
# It has limited functionality, as it only accepts
# jobs as procs, but that might make it useful if you don't
# need anything as big as Redis.
# Saves jobs into a file as YAML as long as they're not procs
# and reloads them when started again.
class HardWorker
  extend Dry::Configurable
  include Singleton unless $TESTING
  URI = "druby://localhost:#{$TESTING ? Array.new(4) { rand(10) }.join : "8788"}"
  FILE_NAME = 'hard_worker_dump'
  @@queue = Queue.new

  setting :rails, true
  setting :rails_path, '.'
  setting :workers, 1
  setting :connect, false

  def initialize
    boot_app
    load_jobs
    @worker_list = []
    HardWorker.config.workers.times do |_i|
      @worker_list << Thread.new { Worker.new }
    end
    return unless HardWorker.config.connect

    DRb.start_service(URI, @@queue, verbose: true)
    puts "listening on #{URI}"
    DRb.thread.join
  end

  def boot_app
    return unless rails?

    ENV['RAILS_ENV'] ||= 'production'
    require_relative "#{HardWorker.config.rails_path}/config/environment.rb"
    require 'rails/all'
    require 'hard_worker/rails'
  end

  def rails?
    HardWorker.config.rails
  end

  def load_jobs
    jobs = YAML.load(File.binread(FILE_NAME))
    jobs.each do |job|
      @@queue.push(job)
    end
    File.delete(HardWorker::FILE_NAME) if File.exist?(HardWorker::FILE_NAME)
  rescue StandardError
    # do nothing
  end

  def reload
    load_jobs
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

  def self.stop_workers
    @worker_list&.each do |worker|
      Thread.kill(worker)
    end
    class_array = []
    @@queue.size.times do |_i|
      next if (klass_or_proc = @@queue.pop).instance_of?(Proc)

      class_array << klass_or_proc
    end
    File.open(FILE_NAME, 'wb') { |f| f.write(YAML.dump(class_array)) }
  end

  def self.clear_queue!
    @@queue.clear
  end

  def job_list
    @@queue
  end

  def self.fetch_job
    @@queue.pop
  end

  class Error < StandardError; end
end
