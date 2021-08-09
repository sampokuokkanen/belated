require 'dumdum'

RSpec.describe Belated do
  it 'can enqueue classes too' do
    Belated.configure do |config|
      config.rails = false
    end
    worker = Belated.new
    5.times do
      worker.job_list.push(
        Belated::JobWrapper.new(job: DumDum.new)
      )
    end
    sleep 0.2
    expect(worker.job_list.length).to eq 0
  end
end
