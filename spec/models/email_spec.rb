require 'rails_helper'

RSpec.describe Email, type: :model do
  it "can be created with address and destinations" do
    email = Email.create!(address: 'test', destinations: 'user@example.com')
    expect(email).to be_persisted
  end
end
