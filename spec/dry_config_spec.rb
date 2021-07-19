RSpec.describe HardWorker do
  describe 'settings with Dry::Configurable' do
    it 'allows you to set Rails to false' do
      HardWorker.config.rails = false
      HardWorker.config.connect = false
      HardWorker.new
      expect(defined?(HardWorker::Rails)).to be_nil
    end
  end
end