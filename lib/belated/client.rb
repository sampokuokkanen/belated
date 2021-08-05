class Belated
  # The client class is responsible for managing the connection to the
  # DRb server. If it has no connection, it adds the jobs to a bank queue.
  # You can enqueue jobs to be processed by the server.
  # Example:
  #   client = Belated::Client.new
  #   client.enqueue(JubJub.new, at: Time.now + 5.seconds)
  class Client
    attr_accessor :queue, :bank, :banker_thread

    # Starts up the client.
    # Connects to the queue through DRb.
    # @return [void]
    def initialize
      server_uri = Belated::URI
      # @bank =
      DRb.start_service
      self.bank = Thread::Queue.new
      self.queue = DRbObject.new_with_uri(server_uri)
      self.banker_thread = Thread.new do
        loop do
          sleep 0.05
          next unless (job, at = bank.pop)

          perform(job, at: at)
        end
      end
    end

    # The method that pushes the jobs to the queue.
    # If there is no connection, it pushes the job to the bank.
    # @param job [Object] - The the job to be pushed.
    # @param at [Date] - The time at which the job should be executed.
    # @return [Object] - The job that was pushed.
    def perform(job, at: nil)
      queue.push(job, at: at)
    rescue DRb::DRbConnError
      bank.push([job, at])
    end
    alias perform_belated perform
    alias perform_later perform
  end
end
