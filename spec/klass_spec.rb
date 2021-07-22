require 'dumdum'

RSpec.describe HardWorker do
  it 'can enqueue classes too' do
    HardWorker.configure do |config|
      config.rails = false
    end
    worker = HardWorker.new
    10.times do
      worker.job_list.push(DumDum.new)
    end
    sleep 0.1
    expect(worker.job_list.empty?).to be_truthy
    worker.stop_workers
  end
end
