require 'dummy_worker'
require 'rails_helper'

RSpec.describe HardWorker do
  before do
    HardWorker.configure do |config|
      config.rails = true
      config.workers = 1
    end
    @worker = Thread.new { HardWorker.new }
    @dummy = DummyWorker.new
  end

  after do
    @worker.kill
  end

  it 'Runs the code in the background, so the count does not change immediately' do
    expect {
      @dummy.queue.push(proc { User.create!(name: 'David') })
    }.to change(User, :count).by(0)
    expect {
      sleep 0.05
    }.to change(User, :count).by(1)
  end
end
