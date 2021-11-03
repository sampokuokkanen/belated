# frozen_string_literal: true

require_relative 'belated/logging'
require_relative 'belated/version'
require_relative 'belated/worker'
require 'belated/client'
require 'belated/job_wrapper'
require 'belated/queue'
require 'ruby2_keywords'
require 'drb'
require 'dry-configurable'
require 'logger'
require 'singleton'
require 'yaml'

# Belated is a pure Ruby job backend.
# It has limited functionality, as it only accepts
# jobs as procs, but that might make it useful if you don't
# need anything as big as Redis.
# Saves jobs into a file as YAML as long as they're not procs
# and reloads them when started again.
class Belated
  extend Dry::Configurable
  include Logging
  include Singleton unless $TESTING

  setting :rails, default: true
  setting :rails_path, default: '.'
  setting :workers, default: 1
  setting :connect, default: true
  setting :env, default: 'production', reader: true
  setting :logger, default: Logger.new($stdout), reader: true
  setting :log_level, default: :info, reader: true
  setting :host, default: 'localhost', reader: true
  setting :port, default: '8788', reader: true
  setting :heartbeat, default: 1, reader: true
  setting :client_heartbeat, default: 5, reader: true
  setting :basic_auth, reader: true do
    setting :name, default: 'Belated'
    setting :password, default: 'Belated123'
  end

  URI = "druby://#{Belated.host}:#{Belated.port}"
  @@queue = Belated::Queue.new

  # Since it's running as a singleton, we need something to start it up.
  # Aliased for testing purposes.
  # This is only run from the bin file.
  def start
    boot_app && @@queue.load_jobs
    @worker_list = []
    Belated.config.workers.times do |i|
      @worker_list << Thread.new { Worker.new(number: i.next) }
    end
    return unless Belated.config.connect

    connect!
    banner_and_info
    trap_signals
    @@queue.enqueue_future_jobs
  end
  alias initialize start

  # Handles connection to DRb server.
  def connect!
    i = 0
    DRb.start_service(URI, @@queue, verbose: true)
  rescue DRb::DRbConnError, Errno::EADDRINUSE
    sleep 0.1 and retry if (i += 1) < 5
    error 'Could not connect to DRb server.'
  end

  def trap_signals
    %w[INT TERM].each do |signal|
      Signal.trap(signal) do
        @worker_list.length.times do
          @@queue.push(:shutdown)
        end
        Thread.new { stop_workers }
        # Max 40 seconds to shutdown
        timeout = 0
        until (timeout += 0.1) >= 40 || @@queue.empty? || $TESTING
          sleep 0.1
        end
        exit
      end
    end
  end

  def boot_app
    return unless rails?

    ENV['RAILS_ENV'] ||= Belated.env
    require File.expand_path("#{Belated.config.rails_path}/config/environment.rb")
    require 'rails/all'
    require 'active_job/queue_adapters/belated_adapter'
  end

  def rails?
    Belated.config.rails
  end

  def reload
    log 'reloading...'
    @@queue.load_jobs
  end

  def stop_workers
    @worker_list&.each do |worker|
      i = 0
      sleep 0.1 while worker.alive? || (i + 0.1) < 10
      Thread.kill(worker)
    end
    @@queue.save_jobs
    exit unless $TESTING
  end

  def banner
    <<-'BANNER'

    .----------------. .----------------. .----------------. .----------------. .----------------. .----------------. .----------------.
    | .--------------. | .--------------. | .--------------. | .--------------. | .--------------. | .--------------. | .--------------. |
    | |   ______     | | |  _________   | | |   _____      | | |      __      | | |  _________   | | |  _________   | | |  ________    | |
    | |  |_   _ \    | | | |_   ___  |  | | |  |_   _|     | | |     /  \     | | | |  _   _  |  | | | |_   ___  |  | | | |_   ___ `.  | |
    | |    | |_) |   | | |   | |_  \_|  | | |    | |       | | |    / /\ \    | | | |_/ | | \_|  | | |   | |_  \_|  | | |   | |   `. \ | |
    | |    |  __'.   | | |   |  _|  _   | | |    | |   _   | | |   / ____ \   | | |     | |      | | |   |  _|  _   | | |   | |    | | | |
    | |   _| |__) |  | | |  _| |___/ |  | | |   _| |__/ |  | | | _/ /    \ \_ | | |    _| |_     | | |  _| |___/ |  | | |  _| |___.' / | |
    | |  |_______/   | | | |_________|  | | |  |________|  | | ||____|  |____|| | |   |_____|    | | | |_________|  | | | |________.'  | |
    | |              | | |              | | |              | | |              | | |              | | |              | | |              | |
    | '--------------' | '--------------' | '--------------' | '--------------' | '--------------' | '--------------' | '--------------' |
     '----------------' '----------------' '----------------' '----------------' '----------------' '----------------' '----------------'
    BANNER
  end

  def banner_and_info
    log banner
    log "Currently running Belated version #{Belated::VERSION} in #{Belated.env}"
    log %(Belated running #{@worker_list&.length.to_i} workers on #{URI}...)
  end

  def stats
    {
      jobs: @@queue.size,
      workers: @worker_list&.length
    }
  end

  class << self
    def find(job_id)
      @@queue.find(job_id)
    end

    def delete(job_id)
      job = find(job_id)
      @@queue.delete_job(job)
    end

    def kill_and_clear_queue!
      @worker_list&.each do |worker|
        Thread.kill(worker)
      end
      clear_queue!
    end

    def all_future_jobs
      @@queue.future_jobs
    end

    def clear_queue!
      @@queue.clear
    end

    def fetch_job
      @@queue.pop
    end
  end

  def job_list
    @@queue
  end

  def self.job_list
    @@queue
  end
end
if defined?(::Rails)
  require 'active_job/queue_adapters/belated_adapter'
  require 'belated/engine'
end
