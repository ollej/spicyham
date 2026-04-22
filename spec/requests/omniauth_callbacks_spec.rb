require 'rails_helper'

RSpec.describe "OmniAuth Callbacks", type: :request do
  let(:auth_hash) do
    OmniAuth::AuthHash.new(
      provider: 'google_oauth2',
      uid: uid,
      info: { email: email }
    )
  end

  before do
    OmniAuth.config.mock_auth[:google_oauth2] = auth_hash
  end

  after do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end

  describe "existing user" do
    let(:user) { create(:user) }
    let(:uid) { user.uid }
    let(:email) { user.email }

    it "signs in and redirects" do
      post "/users/auth/google_oauth2"
      follow_redirect!
      expect(response).to be_redirect
    end
  end

  describe "new user with registration enabled" do
    let(:uid) { 'new-uid-99999' }
    let(:email) { 'newuser@example.com' }

    it "registers the user" do
      ENV['ALLOW_USER_REGISTRATION'] = '1'

      expect {
        post "/users/auth/google_oauth2"
        follow_redirect!
      }.to change(User, :count).by(1)
    ensure
      ENV.delete('ALLOW_USER_REGISTRATION')
    end
  end

  describe "new user with registration disabled" do
    let(:uid) { 'unknown-uid-88888' }
    let(:email) { 'unknown@example.com' }

    it "rejects the user" do
      post "/users/auth/google_oauth2"
      follow_redirect!
      expect(response).to be_redirect
    end
  end
end
