RSpec.describe Belated::Queue do
  it 'will not crash with the shutdown symbol' do
    queue = Belated::Queue.new
    queue.push(:shutdown)
    expect(queue.length).to eq(1)
  end

  it 'logs the completed jobs' do
    # queue = Belated::Queue.new
  end
end
