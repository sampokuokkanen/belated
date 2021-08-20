require 'belated/job_wrapper'
require 'singleton'
class Belated
  # The client class is responsible for managing the connection to the
  # DRb server. If it has no connection, it adds the jobs to a bank queue.
  # You can enqueue jobs to be processed by the server.
  # Example:
  #   client = Belated::Client.new
  #   client.enqueue(JubJub.new, at: Time.now + 5.seconds)
  class Client
    include Singleton unless $TESTING

    attr_accessor :queue, :bank, :banker_thread, :proc_table

    # Starts up the client.
    # Connects to the queue through DRb.
    # @return [void]
    def start
      server_uri = Belated::URI
      DRb.start_service
      self.proc_table = {}
      self.bank = Thread::Queue.new
      self.queue = DRbObject.new_with_uri(server_uri)
      @started = true
      @mutex = Mutex.new
    end
    alias initialize start

    def started?
      @started
    end

    # Thread in charge of handling the bank queue.
    # You probably want to memoize the client in order to avoid
    # having many threads in the sleep state.
    # @return [void]
    def start_banker_thread
      self.banker_thread = Thread.new do
        loop do
          delete_from_table
          if bank.empty?
            sleep 10
            next
          end
          begin
            queue.push(wrapper = bank.pop)
          rescue DRb::DRbConnError
            bank.push(wrapper)
          end
        end
      end
    end

    def delete_from_table
      return if proc_table.empty?

      proc_table.select { |_k, v| v.completed }.each do |key, _value|
        @mutex.synchronize do
          proc_table.delete(key)
        end
      end
    end

    # The method that pushes the jobs to the queue.
    # If there is no connection, it pushes the job to the bank.
    # @param job [Object] - The the job to be pushed.
    # @param at [Date] - The time at which the job should be executed.
    # @param max_retries [Integer] - Times the job should be retried if it fails.
    # @return [JobWrapper] - The job wrapper for the queue.
    def perform(job, at: nil, max_retries: 5)
      job_wrapper = wrap_job(job, at: at, max_retries: max_retries)
      bank.push(job_wrapper)
      @mutex.synchronize do
        proc_table[job_wrapper.object_id] = job_wrapper if job_wrapper.proc_klass
      end
      start_banker_thread if banker_thread.nil?
      job_wrapper
    end
    alias perform_belated perform
    alias perform_later perform

    private

    def wrap_job(job, at:, max_retries:)
      return job if job.is_a?(JobWrapper)

      JobWrapper.new(job: job, at: at, max_retries: max_retries)
    end

    def drb_connected?
      queue.connected?
    rescue StandardError
      false
    end
  end
end
