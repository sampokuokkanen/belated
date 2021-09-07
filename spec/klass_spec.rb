require 'dumdum'

RSpec.describe Belated do
  before :all do
    Belated.configure do |config|
      config.workers = 1
      config.rails = false
      config.connect = true
    end
    @worker = Thread.new { Belated.new }
    @client = Belated::Client.new
  end
  
  after :all do
    @client.turn_off
    @worker.kill
  end

  it 'can enqueue classes too' do
    3.times do
      @client.perform(
        DumDum.new
      )
    end
    sleep 0.05
    expect(@client.queue.length).to eq 0
  end

  it 'supports args' do
    @client.perform(
      DumDumArgs.new
    )
    sleep 0.05
    expect(@client.queue.length).to eq 0
  end

  it 'supports keyword args' do
    @client.perform(
      DumDumKwargs.new
    )
    sleep 0.05
    expect(@client.queue.length).to eq 0
  end
end
