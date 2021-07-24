class Belated
  class Client
    attr_accessor :queue

    def initialize
      server_uri = Belated::URI
      DRb.start_service
      self.queue = DRbObject.new_with_uri(server_uri)
    end

    def perform_belated(job)
      queue.push(job)
    end
    alias perform_later perform_belated
  end
end
