# frozen_string_literal: true
require 'dummy_worker'
require 'dumdum'

RSpec.describe HardWorker do
  describe 'job processing' do
    it 'allows you to run code in the background' do
      HardWorker.config.rails = false
      HardWorker.config.connect = true
      HardWorker.config.workers = 1
      thread = Thread.new {
        HardWorker.new
      }
      dummy = DummyWorker.new
      dummy.queue.push(DumDum.new)
      sleep 0.05
      expect(dummy.queue.empty?).to be_truthy
      thread.kill
    end
  end
end
