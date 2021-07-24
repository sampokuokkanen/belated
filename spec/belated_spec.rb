# frozen_string_literal: true

RSpec.describe Belated do
  describe 'basics' do
    before do
      Belated.config.connect = false
      Belated.config.rails = false
      Belated.config.workers = 0
    end

    it 'should have a version number' do
      expect(Belated::VERSION).not_to be nil
    end

    describe 'Belated::Worker' do
      it 'has a Worker class defined' do
        expect(Belated::Worker).not_to be nil
      end

      it 'the worker class has a method that returns all jobs' do
        expect(Belated.new.job_list).to be_empty
      end
    end

    it 'remembers the jobs it has enqued even if restarted' do
      worker = Belated.new
      expect {
        worker.job_list.push(DumDum.new)
        worker.stop_workers
        worker.reload
      }.to change { worker.job_list.length }.by 0
    end
  end

  describe 'job processing' do
    it 'allows you to run code in the background' do
      Belated.configure do |config|
        config.rails = false
      end

      worker = Belated.new
      worker.job_list.push(proc { puts 'hello' })
      expect(worker.job_list.length).to eq 1
      sleep 0.01
      expect(worker.job_list.empty?).to be_truthy
      worker.stop_workers
    end
  end
end
