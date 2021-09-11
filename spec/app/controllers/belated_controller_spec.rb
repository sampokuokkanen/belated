require 'rails_helper'
RSpec.describe Belated::BelatedController, type: :controller do
  routes { Belated::Engine.routes }
  render_views
  it 'has an index page' do
    get 'index'
    expect(response.status).to eq 200
    expect(response.body).to include 'Belated'
  end

  it 'accepts post requests' do
    post 'index', params: { job_id: '1' }
    expect(response.status).to eq 200
    expect(response.body).to include 'Belated'
  end
end
