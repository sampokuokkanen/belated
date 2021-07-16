require 'dumdum'

RSpec.describe HardWorker do
  after(:all) do
    File.delete(HardWorker::FILE_NAME)
  end

  it 'remembers the jobs it has enqued even if restarted' do
    worker = HardWorker.new(workers: 0)
    5.times do
      worker.job_list.push(DumDum.new)
    end
    worker.stop_workers
    # Simulate shutdown
    worker.reset_queue!
    second_worker = HardWorker.new(workers: 0)
    expect(second_worker.job_list.empty?).to be_falsey
    expect(second_worker.job_list.length).to eq 5
  end
end
