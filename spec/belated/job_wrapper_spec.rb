RSpec.describe Belated::JobWrapper do
  subject = described_class.new(max_retries: 1, job: proc { 1 / 2 })

  describe '#initialize' do
    it 'should have an option for retry count' do
      expect(subject.max_retries).to eq(1)
      expect(subject.id).not_to be_nil
    end
  end
end
