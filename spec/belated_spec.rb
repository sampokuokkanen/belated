# frozen_string_literal: true

require 'dumdum'

RSpec.describe Belated do
  before :all do
    @port = Belated.config.port
    Belated.config.port = '1234'
  end
  after :all do
    Belated.config.port = @port
  end
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
        expect(Belated.new.job_list.class).to eq Belated::Queue
      end
    end

    context 'remembering jobs during restart' do
      before do
        Belated.config.workers = 0
        Belated.config.connect = false
        @worker = Belated.new
        Belated.kill_and_clear_queue!
      end

      it 'remembers the jobs it has enqued even if restarted' do
        15.times do
          @worker.job_list.push(
            Belated::JobWrapper.new(
              job: DumDum.new(sleep: 10)
            )
          )
        end
        @worker.stop_workers
        @worker.reload
        expect(@worker.job_list.empty?).to be_falsey
      end

      it 'remembers future jobs it has enqued even if restarted' do
        5.times do
          @worker.job_list.push(
            Belated::JobWrapper.new(
              job: DumDum.new(sleep: 1),
              at: (Time.now + 500).to_f
            )
          )
        end
        expect {
          @worker.stop_workers
          @worker.reload
        }.to change(@worker.job_list.future_jobs.reject { |j| j.instance_of?(Proc) }, :length).by 0
      end
    end
  end

  describe 'job processing' do
    before do
      Belated.configure do |config|
        config.rails = false
        config.workers = 1
      end

      @worker = Belated.new
    end

    it 'will not crash with syntax errors' do
      expect {
        @worker.job_list.push(
          Belated::JobWrapper.new(
            job: proc { raise SyntaxError }
          )
        )
        sleep 0.01
      }.not_to raise_error
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

    it 'allows you to run code in the background' do
      @worker.job_list.push(
        Belated::JobWrapper.new(job: proc { puts 'hello' })
      )
      expect(@worker.job_list.length).to eq 1
      sleep 0.02
      expect(@worker.job_list.empty?).to be_truthy
      Belated.kill_and_clear_queue!
    end

    it 'is possible to find and delete a job' do
      job = Belated::JobWrapper.new(job: proc { puts 'hello' }, at: (Time.now + 10).to_f)
      @worker.job_list.push(job)
      sleep 0.01
      expect(Belated.find(job.id)).to eq job
      Belated.delete(job.id)
      expect(Belated.find(job.id)).to be_nil
    end
  end
end
