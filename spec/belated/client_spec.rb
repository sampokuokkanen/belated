require 'byebug'
require 'dumdum'
require 'rails_helper'

RSpec.describe Belated::Client do
  describe 'adding jobs' do
    it 'adds a job to the queue' do
      Belated.configure do |config|
        config.rails = true
        config.workers = 1
        config.connect = true
      end
      worker = Thread.new { Belated.new }
      client = Belated::Client.new
      expect {
        client.perform_belated(proc { User.create!(name: 'Diana') })
        sleep 0.04
      }.to change { User.all.count }.by(1)
      worker.kill
    end
  end
end
