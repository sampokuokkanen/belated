RSpec.describe Belated::JobWrapper do
  subject = described_class.new(max_retries: 1, job: proc { 1 / 2 })

  describe '#initialize' do
    it 'should have an option for retry count' do
      expect(subject.max_retries).to eq(1)
      expect(subject.id).not_to be_nil
    end
  end

  describe '#perform' do
    it 'should retry the job until it succeeds' do
      subject.job = proc { raise 'error' }
      expect {
        subject.perform
      }.to change { subject.retries }.from(0).to(1)
    end

    it 'adds the error to the error field if no more retries' do
      subject.job = proc { raise 'error' }
      subject.max_retries = 0
      subject.perform
      expect(subject.error.class).to eq RuntimeError
    end
  end

  
end
