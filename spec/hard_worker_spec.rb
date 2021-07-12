# frozen_string_literal: true

RSpec.describe HardWorker do

  it "has a version number" do
    expect(HardWorker::VERSION).not_to be nil
  end

  describe "HardWorker::Worker" do
    it "has a Worker class defined" do
      expect(HardWorker::Worker).not_to be nil
    end

    it "the worker class has a method that returns all jobs" do
      expect(HardWorker.job_queue).to be_empty
    end
  end

  describe "job processing" do
    it "allows you to run code in the background" do
      HardWorker.job_queue << proc { puts 'hello' }
      expect(HardWorker.job_queue.length).to eq 1
    end
  end
end
