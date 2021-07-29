# frozen_string_literal: true

require_relative 'belated/version'
require_relative 'belated/worker'
require_relative 'belated/logging'
require 'drb'
require 'yaml'
require 'singleton'
require 'dry-configurable'
require 'belated/client'
require 'logger'

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
  URI = "druby://localhost:8788"
  FILE_NAME = 'belated_dump'
  @@queue = Queue.new

  setting :rails, true
  setting :rails_path, '.'
  setting :workers, 1
  setting :connect, true
  setting :environment, 'development'
  setting :logger, Logger.new($stdout), reader: true
  setting :log_level, :info, reader: true


  # Since it's running as a singleton, we need something to start it up.
  # Aliased for testing purposes.
  # This is only run from the bin file.
  def start
    boot_app
    load_jobs
    @worker_list = []
    Belated.config.workers.times do |_i|
      @worker_list << Thread.new { Worker.new }
    end
    return unless Belated.config.connect

    begin
      DRb.start_service(URI, @@queue, verbose: true)
    rescue DRb::DRbConnError, Errno::EADDRINUSE
      Belated.logger.error 'Could not connect to DRb server.'
      uri = "druby://localhost:#{ Array.new(4) { rand(10) }.join }"
      self.class.send(:remove_const, 'URI')
      self.class.const_set('URI', uri)
      retry
    end

    banner_and_info
    DRb.thread.join
  end
  alias initialize start

  def boot_app
    return unless rails?

    ENV['RAILS_ENV'] ||= Belated.config.environment
    require File.expand_path("#{Belated.config.rails_path}/config/environment.rb")
    require 'rails/all'
    require 'belated/rails'
  end

  def rails?
    Belated.config.rails
  end

  def load_jobs
    log "reloading... if file exists #{File.exist?(Belated::FILE_NAME)}"
    return unless File.exist?(Belated::FILE_NAME)

    jobs = YAML.load(File.binread(FILE_NAME))
    jobs.each do |job|
      @@queue.push(job)
    end
    File.delete(Belated::FILE_NAME)
  end

  def reload
    log 'reloading...'
    load_jobs
  end

  def stop_workers
    @worker_list&.each do |worker|
      Thread.kill(worker)
    end
    class_array = []
    @@queue.size.times do |_i|
      next if (klass = @@queue.pop).instance_of?(Proc)

      class_array << klass
    end
    pp File.open(FILE_NAME, 'wb') { |f| f.write(YAML.dump(class_array)) }
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
    log "Currently running Belated version #{Belated::VERSION}"
    log %(Belated running #{@worker_list&.length.to_i} workers on #{URI}...)
  end

  def stats
    {
      jobs: @@queue.size,
      workers: @worker_list&.length
    }
  end

  def self.kill_and_clear_queue!
    @worker_list&.each do |worker|
      Thread.kill(worker)
    end
    clear_queue!
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

require 'belated/rails' if defined?(::Rails::Engine)
