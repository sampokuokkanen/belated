require 'byebug'
require 'dumdum'
require 'rails_helper'

RSpec.describe Belated::Client do
  describe 'client can recover from not having connection' do
    it 'does not raise an error if there is no connection' do
      client = Belated::Client.new
      expect(client.started?).to be_truthy
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
      sleep 0.14
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
      @client.turn_off
      @worker.kill
    end

    it 'is connected' do
      expect(@client.queue.connected?).to eq(true)
    end

    it 'adds a job to the queue' do
      expect {
        @client.perform_belated(proc { User.create!(name: 'Diana') })
        sleep 0.07
      }.to change { User.all.count }.by(1)
    end

    it 'does not accept something that is not a proper job' do
      expect {
        @client.perform_belated('Hello World!')
      }.to raise_error
    end

    it 'has a date option' do
      now = Time.now
      perform_at = now + 0.3
      @client.perform_belated(
        Belated::JobWrapper.new(
          job: proc { User.create!(name: 'Diana!') },
          at: perform_at
        )
      )
      expect(User.find_by(name: 'Diana!')).to be_nil
      sleep 0.45
      expect(User.find_by(name: 'Diana!')).to be_a User
    end

    it 'keeps the jobs in a table, lets go once done' do
      expect {
        26.times do
          @client.perform(proc { 2 / 1 })
        end
      }.to change { @client.proc_table.length }.by(26)
      sleep 0.15
      expect(@client.proc_table.length).to eq(0)
    end

    it 'will not reset the table if start is called multiple times' do
      expect {
        @client.perform(proc { 2 / 1 })
        @client.start
      }.to change { @client.proc_table.length }.by(1)
    end

    it 'keeps the jobs in a table only if they are procs' do
      expect {
        @client.perform(DumDum.new)
      }.to change { @client.proc_table.length }.by(0)
    end
  end
end
