require 'dummy_worker'
require 'rails_helper'

RSpec.describe Belated do
  before do
    Belated.configure do |config|
      config.rails = true
      config.workers = 1
    end
    @worker = Thread.new { Belated.new }
    DRb.start_service
    @dummy = DummyWorker.new
  end

  after do
    Belated.stop_workers
    @worker.kill
  end

  it 'Runs the code in the background, so the count does not change immediately' do
    expect {
      @dummy.queue.push(
        proc do
          sleep 0.01
          User.create!(name: 'David')
        end
      )
    }.to change(User, :count).by(0)
    expect {
      sleep 0.09
    }.to change(User, :count).by(1)
  end
  User.all.delete_all
end
