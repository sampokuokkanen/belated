# frozen_string_literal: true

RSpec.describe HardWorker do
  class DummyWorker
    attr_accessor :queue

    def initialize
      server_uri = HardWorker::URI
      self.queue = DRbObject.new_with_uri(server_uri)
    end
  end

  describe 'job processing' do
    it 'allows you to run code in the background' do
      worker = Thread.new { HardWorker.new(connect: true) }
      dummy = DummyWorker.new
      sleep(0.05)
      dummy.queue.push(proc { 2 / 1 })
      expect(dummy.queue.length).to eq 1
      sleep(1)
      expect(dummy.queue.empty?).to be_truthy
      worker.exit
    end
  end
end