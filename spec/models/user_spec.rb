require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with factory defaults" do
      expect(build(:user)).to be_valid
    end

    it "is invalid without email" do
      expect(build(:user, email: nil)).not_to be_valid
    end

    it "is invalid without password" do
      expect(build(:user, password: nil)).not_to be_valid
    end

    it "is valid with nil api" do
      expect(build(:user, api: nil)).to be_valid
    end

    it "is invalid with unknown api value" do
      expect { build(:user, api: 'unknown') }.to raise_error(ArgumentError)
    end
  end

  describe "enum" do
    it "defines all API types" do
      expect(User.apis.values).to contain_exactly('gandixmlrpc', 'gandiv5', 'glesys', 'migadu')
    end

    %w[Gandi\ XML/RPC Gandi\ v5 Glesys Migadu].each do |api_name|
      it "can be set to #{api_name}" do
        user = build(:user, api: api_name)
        expect(user.api).to eq(api_name)
      end
    end
  end

  describe "#api_name" do
    it "returns the DB value for the enum" do
      user = build(:user, api: 'Gandi v5')
      expect(user.api_name).to eq('gandiv5')
    end

    it "returns nil when api is nil" do
      user = build(:user, api: nil)
      expect(user.api_name).to be_nil
    end
  end

  describe ".from_omniauth" do
    let(:auth) do
      OmniAuth::AuthHash.new(
        provider: 'google_oauth2',
        uid: '12345',
        info: { email: 'oauth@example.com' }
      )
    end

    it "returns existing user when uid matches" do
      existing = create(:user, uid: '12345')
      result = User.from_omniauth(auth)
      expect(result).to eq(existing)
    end

    it "returns new unpersisted user when uid not found" do
      result = User.from_omniauth(auth)
      expect(result).to be_a(User)
      expect(result).not_to be_persisted
    end

    it "sets provider, uid, and email from auth hash on new user" do
      result = User.from_omniauth(auth)
      expect(result.provider).to eq('google_oauth2')
      expect(result.uid).to eq('12345')
      expect(result.email).to eq('oauth@example.com')
    end
  end
end
