require 'byebug'
require 'dumdum'
require 'rails_helper'

RSpec.describe Belated::Client do
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
        sleep 0.05
      }.to change { User.all.count }.by(1)
    end

    it 'has a date option' do
      now = Time.now.utc
      perform_at = now + 0.5
      @client.perform_belated(
        proc { User.create!(name: 'Diana!') },
        at: perform_at
      )
      expect(User.find_by(name: 'Diana!')).to be_nil
      sleep 0.6
      expect(User.find_by(name: 'Diana!')).to be_a User
    end
  end

  # describe 'client can recover from not having connection' do
  #   client = Belated::Client.new
  #   expect(
  #     client.perform_belated(proc { 2/ 1})
  #   ).not_to raise_error
  # end
end
