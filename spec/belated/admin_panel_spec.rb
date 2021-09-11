require "rails_helper"

RSpec.feature "Belated Admin Panel", type: :feature do
  it 'has an index page' do
    get '/'
    expect(response.status).to eq 200
    expect(response.body).to include 'Belated'
  end
end
