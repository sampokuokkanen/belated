RSpec.describe HardWorker do
  describe 'settings with Dry::Configurable' do
    it 'allows you to set Rails to false' do
      HardWorker.configure do |config|
        config.rails = false
        config.connect = false
        config.workers = 0
      end

      HardWorker.new
      expect(defined?(HardWorker::Rails)).to be_nil
    end
  end
end
