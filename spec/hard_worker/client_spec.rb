require 'byebug'
require 'dumdum'
require 'rails_helper'

RSpec.describe HardWorker::Client do
  describe 'client' do
    it 'has a client class than can be instantiated' do
      expect(HardWorker::Client.new).not_to be nil
    end
  end

  describe 'adding jobs' do
    it 'adds a job to the queue' do
      HardWorker.configure do |config|
        config.rails = true
        config.workers = 1
        config.connect = true
      end
      worker = Thread.new { HardWorker.new }
      client = HardWorker::Client.new
      expect {
        client.perform_belated(proc { User.create!(name: 'Diana') })
        sleep 0.04
      }.to change { User.all.count }.by(1)
      worker.kill
    end
  end
end
