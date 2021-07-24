RSpec.describe Belated do
  describe 'settings with Dry::Configurable' do
    it 'allows you to set Rails to false' do
      Belated.configure do |config|
        config.rails = false
        config.connect = false
        config.workers = 0
      end

      belated = Belated.new
      expect(belated.rails?).to be_falsey
    end
  end
end
