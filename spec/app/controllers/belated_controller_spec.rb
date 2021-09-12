require 'rails_helper'
require 'dumdum'
RSpec.describe Belated::AdminController, type: :controller do
  routes { Belated::Engine.routes }
  render_views

  before :all do
    Belated.configure do |config|
      config.rails = false
      config.connect = true
      config.workers = 1
    end

    @worker = Thread.new { Belated.new }
    @client = Belated::Client.new
  end

  after :all do
    @worker.kill
    @client.turn_off
  end

  it 'has an index page' do
    get 'index'
    expect(response.status).to eq 200
    expect(response.body).to include 'Belated'
  end

  it 'accepts post requests' do
    job = @client.perform_belated(DumDum.new, at: Time.now + 400)
    sleep 0.1
    post 'index', params: { job_id: job.id }
    expect(response.status).to eq 200
    expect(response.body).to include 'Belated'
    expect(response.body).to include 'DumDum'
  end
end
