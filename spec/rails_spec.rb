RSpec.describe HardWorker do
  xit 'has access to Rails internals' do
    expect(::Rails::Engine).to be_defined
  end
end
