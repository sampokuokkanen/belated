require 'rails_helper'
require 'active_job/queue_adapters/belated_adapter'

RSpec.describe ActiveJob::QueueAdapters::BelatedAdapter do
  before do
    Belated.configure do |config|
      config.rails = true
      config.workers = 1
    end
    @worker = Thread.new { Belated.new }
  end

  after do
    @worker.kill
  end

  it 'inherits from Belated::Adapter' do
    expect(described_class).not_to be_nil
  end

  it 'should be able to perform a job using perform_now' do
    ActiveJob::Base.queue_adapter = :belated
    expect(TestJob.perform_now).to eq 'Test job'
  end

  it 'works with perform_later' do
    expect {
      TestJob.perform_later
    }.not_to raise_error
  end

  it 'will create a user at a later date if given one' do
    expect {
      CreateUserJob.set(wait_until: Time.now + 0.1).perform_later
      sleep 1
    }.to change(User, :count).by(1)
  end

  describe '#send_mail' do
    subject(:mail) do
      TestMailer.send_mail.deliver_later
      sleep 0.15
      ActionMailer::Base.deliveries.last
    end

    context 'when send_mail' do
      it { expect(mail.to.first).to eq('hoge.from@test.com') }
      it { expect(mail.from.first).to eq('fuga.to@test.com') }
      it { expect(mail.subject).to eq('ほげ商事の田中太郎です') }
      it { expect(mail.body).to match(/本メールはほげ商事の田中太郎からのテストメールです。/) }
    end
  end
end
