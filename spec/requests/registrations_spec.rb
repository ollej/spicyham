require 'rails_helper'

RSpec.describe "Registrations", type: :request do
  let(:user) { create(:user) }

  describe "unauthenticated" do
    it "redirects from edit" do
      get edit_user_registration_path
      expect(response).to be_redirect
    end
  end

  describe "authenticated" do
    before { sign_in user }

    describe "GET /users/edit" do
      it "renders the edit profile form" do
        get edit_user_registration_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include('Edit profile')
      end
    end

    describe "PUT /users/:id" do
      it "updates user domain and default_forward" do
        put user_registration_path(user), params: {
          user: { domain: 'newdomain.com', default_forward: 'new@example.com' }
        }
        expect(response).to be_redirect

        user.reload
        expect(user.domain).to eq('newdomain.com')
        expect(user.default_forward).to eq('new@example.com')
      end

      it "updates API settings" do
        put user_registration_path(user), params: {
          user: { api: 'Glesys', api_key: 'newkey', api_user: 'newuser' }
        }
        expect(response).to be_redirect

        user.reload
        expect(user.api).to eq('Glesys')
        expect(user.api_key).to eq('newkey')
        expect(user.api_user).to eq('newuser')
      end

      it "updates alias template" do
        put user_registration_path(user), params: {
          user: { alias_template: '{RANDOM}-{DOMAIN}' }
        }
        expect(response).to be_redirect

        user.reload
        expect(user.alias_template).to eq('{RANDOM}-{DOMAIN}')
      end
    end
  end
end
