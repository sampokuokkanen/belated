require 'byebug'
require 'dumdum'
require 'rails_helper'

RSpec.describe Belated::Client do
  describe 'client can recover from not having connection' do
    it 'does not raise an error if there is no connection' do
      client = Belated::Client.new
      expect {
        client.perform_belated(proc { 2 / 1 })
      }.not_to raise_error
      expect(client.bank.length).to eq(1)
    end

    it 'performs the jobs once Belated is started' do
      client = Belated::Client.new
      client.perform_belated(proc { 2 / 1 })
      expect(client.bank.length).to eq(1)
      Belated.configure do |config|
        config.rails = false
        config.workers = 1
        config.connect = true
      end
      @worker = Thread.new { Belated.new }
      sleep 0.1
      expect(client.bank.length).to eq(0)
      @worker.kill
    end
  end

  describe 'adding jobs' do
    before do
      Belated.configure do |config|
        config.rails = true
        config.workers = 1
        config.connect = true
      end
      @worker = Thread.new { Belated.new }
      @client = Belated::Client.new
    end

    after do
      @worker.kill
    end

    it 'adds a job to the queue' do
      expect {
        @client.perform_belated(proc { User.create!(name: 'Diana') })
        sleep 0.06
      }.to change { User.all.count }.by(1)
    end

    it 'has a date option' do
      now = Time.now.utc
      perform_at = now + 0.5
      @client.perform_belated(
        Belated::JobWrapper.new(
          job: proc { User.create!(name: 'Diana!') },
          at: perform_at
        )
      )
      expect(User.find_by(name: 'Diana!')).to be_nil
      sleep 1.63
      expect(User.find_by(name: 'Diana!')).to be_a User
    end

    it 'retries the jobs' do
      'To be continued'
    end
  end
end
