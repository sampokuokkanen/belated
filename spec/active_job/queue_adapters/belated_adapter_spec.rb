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
    u = CreateUserJob.set(wait_until: Time.now + 0.01).perform_later(name: 'John Doe')
    expect(u.job_id).not_to be_nil
    sleep 0.35
    expect(User.find_by_name('John Doe')).to be_an_instance_of User
  end

  describe '#send_mail' do
    subject(:mail) do
      TestMailer.send_mail.deliver_later
      sleep 0.25
      ActionMailer::Base.deliveries.last
    end

    context 'when send_mail' do
      it 'actually sends the emails' do
        expect(mail.to.first).to eq('hoge.from@test.com')
        expect(mail.body).to match(/本メールはほげ商事の田中太郎からのテストメールです。/)
        expect(mail.from.first).to eq('fuga.to@test.com')
        expect(mail.subject).to eq('ほげ商事の田中太郎です')
      end
    end
  end
end
