# frozen_string_literal: true

RSpec.describe HardWorker do
  it 'has a version number' do
    expect(HardWorker::VERSION).not_to be nil
  end

  describe 'HardWorker::Worker' do
    it 'has a Worker class defined' do
      expect(HardWorker::Worker).not_to be nil
    end

    it 'the worker class has a method that returns all jobs' do
      expect(HardWorker.new.job_list).to be_empty
    end
  end

  describe 'job processing' do
    it 'allows you to run code in the background' do
      worker = HardWorker.new
      worker.job_list.push(proc { puts 'hello' })
      expect(worker.job_list.length).to eq 1
      sleep(1)
      expect(worker.job_list.empty?).to be_truthy
      worker.stop_workers
    end
  end
end
