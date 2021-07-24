class DummyWorker
  attr_accessor :queue

  def initialize
    server_uri = Belated::URI
    self.queue = DRbObject.new_with_uri(server_uri)
  end
end
