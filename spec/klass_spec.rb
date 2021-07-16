require 'dumdum'

RSpec.describe HardWorker do
  it 'can enqueue classes too' do
    worker = HardWorker.new
    10.times do
      worker.job_list.push(DumDum.new)
    end
    sleep 0.2
    expect(worker.job_list.empty?).to be_truthy
  end
end