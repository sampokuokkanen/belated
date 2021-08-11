# frozen_string_literal: true

require 'dummy_worker'
require 'dumdum'

RSpec.describe Belated do
  describe 'job processing' do
    it 'allows you to run code in the background' do
      Belated.config.rails = false
      Belated.config.connect = true
      Belated.config.workers = 1
      thread = Thread.new { Belated.new }
      dummy = DummyWorker.new
      dummy.queue.push(Belated::JobWrapper.new(job: DumDum.new))
      sleep 0.05
      expect(dummy.queue.empty?).to be_truthy
      thread.kill
    end
  end
end
