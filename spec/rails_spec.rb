require 'dummy_worker'
require 'rails_helper'

RSpec.describe Belated do
  before do
    Belated.configure do |config|
      config.rails = true
      config.workers = 1
    end
    @worker = Thread.new { Belated.new }
    @dummy = DummyWorker.new
  end

  after do
    @worker.kill
  end

  it 'Runs the code in the background, so the count does not change immediately' do
    expect {
      @dummy.queue.push(
        Belated::JobWrapper.new(job:
          proc do
            sleep 0.1
            User.create!(name: 'David')
          end)
      )
    }.to change { User.where(name: 'David').count }.by(0)
    expect {
      sleep 0.11
    }.to change { User.where(name: 'David').count }.by(1)
  end
end
