RSpec.describe Belated::Worker do
  before do
    Belated.configure do |config|
      config.rails = false
      config.connect = true
      config.workers = 1
    end

    @worker = Thread.new { Belated.new }
    @client = Belated::Client.new
  end

  after do
    @worker.kill
    @client.turn_off
  end

  it 'does not stop processing jobs if there is a crash' do
    @client.perform_belated(proc { 2 / 0 })
    sleep 0.01
    @client.perform_belated(proc { 4 / 2 })
    sleep 0.01
    expect(@client.queue.length).to eq 0
  end

  it 'does not fail if the object is garbage collected' do
    @client.perform_belated(proc { raise Errno::ECONNREFUSED })
    @client.perform_belated(proc { 4 / 2 })
    sleep 0.01
    expect(@client.queue.length).to eq 0
  end
end
