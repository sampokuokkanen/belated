# frozen_string_literal: true
require 'dumdum'

class DummyWorker
  attr_accessor :queue

  def initialize
    server_uri = HardWorker::URI
    self.queue = DRbObject.new_with_uri(server_uri)
  end
end

RSpec.describe HardWorker do
  after(:all) do
    worker = HardWorker.new
    worker.reset_queue!
  end

  describe 'job processing' do
    it 'allows you to run code in the background' do
      Thread.new { HardWorker.new(connect: true) }
      dummy = DummyWorker.new
      dummy.queue.push(DumDum.new)
      sleep 0.05
      expect(dummy.queue.empty?).to be_truthy
    end
  end
end
