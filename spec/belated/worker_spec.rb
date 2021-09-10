require 'dumdum'

RSpec.describe Belated::Worker do
  before :all do
    Belated.configure do |config|
      config.rails = false
      config.connect = true
      config.workers = 1
    end

    @worker = Thread.new { Belated.new }
    @client = Belated::Client.new
  end

  after :all do
    @worker.kill
    @client.turn_off
  end

  it 'does not stop processing jobs if there is a crash' do
    @client.perform_belated(proc { 2 / 0 }, max_retries: 0)
    sleep 0.01
    @client.perform_belated(proc { 4 / 2 })
    sleep 0.01
    expect(@client.queue.length).to eq 0
  end

  it 'does not fail if the object is garbage collected' do
    @client.perform_belated(proc { raise Errno::ECONNREFUSED }, max_retries: 0)
    @client.perform_belated(proc { 4 / 2 })
    sleep 0.01
    expect(@client.queue.length).to eq 0
  end

  it 'keeps tabs on the history for jobs that are not procs' do
    job = @client.perform_belated(DumDum.new)
    expect(job.completed).to be_falsey
    sleep 0.04
    today = Time.now.strftime('%F')
    store = PStore.new("history_#{Belated.environment}-#{today}.pstore", true)
    stored_job = nil
    store.transaction(true) do
      stored_job = store[job.id]
    end
    expect(stored_job.completed).to be_truthy
  end
end
