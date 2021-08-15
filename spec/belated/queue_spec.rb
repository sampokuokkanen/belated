RSpec.describe Belated::Queue do
  it 'will not crash with the shutdown symbol' do
    queue = Belated::Queue.new
    queue.push(:shutdown)
    expect(queue.length).to eq(1)
  end

  it 'has the future jobs in order' do
    queue = Belated::Queue.new
    jobs = [Belated::JobWrapper.new(at: Time.now + 16, job: 'hello'),
            Belated::JobWrapper.new(at: Time.now + 7, job: 'hello')]
    queue.push(jobs[0])
    queue.push(jobs[1])
    expect(queue.future_jobs.to_a).to eq jobs.reverse
  end

  it 'will rescue DRb::DRbRemoteError' do
    expect {
      @worker.job_list.push(
        Belated::JobWrapper.new(
          job: proc { raise DRb::DRbRemoteError }
        )
      )
      sleep 0.01
    }.not_to raise_error
  end

  it 'logs the completed jobs' do
    # queue = Belated::Queue.new
  end
end
