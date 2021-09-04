require 'rails_helper'
require 'active_job/queue_adapters/belated_adapter'

RSpec.describe ActiveJob::QueueAdapters::BelatedAdapter do
  before :context do
    Belated.configure do |config|
      config.rails = true
      config.workers = 2
      config.connect = true
    end
    @worker = Thread.new { Belated.new }
  end

  after :context do
    @worker.kill
  end

  it 'inherits from Belated::Adapter' do
    expect(described_class).not_to be_nil
  end

  it 'should be able to perform a job using perform_now' do
    expect(TestJob.perform_now).to eq 'Test job'
  end

  it 'works with perform_later' do
    expect {
      TestJob.perform_later
    }.not_to raise_error
  end

  it 'will create a user at a later date if given one' do
    u = CreateUserJob.set(wait_until: Time.now + 0.2).perform_later(name: 'John Doe')
    sleep 0.05
    job = Belated.find(u.job_id)
    expect(job.id).to eq u.job_id
    expect(u.job_id).not_to be_nil
    sleep 0.39
    expect(User.find_by_name('John Doe')).to be_an_instance_of User
  end

  it 'can use the ActiveJob retry mechanism' do
    fail_job = FailJob.set(wait_until: Time.now + 0.05).perform_later
    sleep 0.07
    job = Belated.find(fail_job.job_id)
    expect(job.job.exception_executions).to eq({ '[RuntimeError]' => 1 })
    sleep 0.07
    job = Belated.find(fail_job.job_id)
    expect(job.job.exception_executions).to eq({ '[RuntimeError]' => 2 })
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
