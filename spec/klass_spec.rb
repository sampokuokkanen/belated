require 'dumdum'

RSpec.describe Belated do
  it 'can enqueue classes too' do
    Belated.configure do |config|
      config.rails = false
    end
    worker = Belated.new
    10.times do
      worker.job_list.push(DumDum.new)
    end
    sleep 0.1
    expect(worker.job_list.empty?).to be_truthy
  end
end
