require 'dumdum'

RSpec.describe Belated::Queue do
  it 'will not crash with the shutdown symbol' do
    queue = Belated::Queue.new
    queue.push(:shutdown)
    expect(queue.length).to eq(1)
  end

  it 'has the future jobs in order' do
    queue = Belated::Queue.new
    jobs = [Belated::JobWrapper.new(at: (Time.now + 16).to_f, job: DumDum.new),
            Belated::JobWrapper.new(at: (Time.now + 7).to_f, job: DumDum.new)]
    queue.push(jobs[0])
    queue.push(jobs[1])
    expect(queue.future_jobs.to_a).to eq jobs.reverse
  end

  it 'has the new jobs in PStore as backup' do
    queue = Belated::Queue.new
    job = Belated::JobWrapper.new(at: (Time.now + 16).to_f, job: DumDum.new)
    queue.push(job)
    stored_job = nil
    queue.future_jobs_db.transaction(true) do
      stored_job = queue.future_jobs_db[job.id]
    end
    expect(stored_job).to eq job
  end
end
