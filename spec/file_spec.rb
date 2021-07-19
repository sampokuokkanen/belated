require 'dumdum'

RSpec.describe HardWorker do
  it 'remembers the jobs it has enqued even if restarted' do
    HardWorker.config.workers = 0
    HardWorker.config.rails = false
    worker = HardWorker.new
    worker.job_list.push(DumDum.new)
    expect {
      worker.stop_workers
      worker.reload
    }.to change { worker.job_list.length }.by 0
  end
end
