require 'belated/testing'

RSpec.describe Belated::Testing do
  it 'overrides the perform method to inline' do
    Belated::Testing.inline!
    client = Belated::Client.new
    expect(
      client.perform(proc {
        4 / 2
      })
    ).to eq(2)
    Belated::Testing.test_mode_off!
  end
end
