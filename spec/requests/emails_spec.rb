require 'rails_helper'

RSpec.describe "Emails", type: :request do
  let(:user) { create(:user) }
  let(:mock_api) { double("Facade::API", list: [], create: nil, delete: nil) }

  before do
    allow(Facade::API).to receive(:create).and_return(mock_api)
  end

  describe "unauthenticated" do
    it "redirects from index" do
      get emails_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects from create" do
      post emails_path, params: { address: 'test', destinations: 'test@example.com' }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects from destroy" do
      delete email_path('test')
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /emails" do
    before { sign_in user }

    it "renders successfully with empty list" do
      get emails_path
      expect(response).to have_http_status(:success)
    end

    it "displays emails from API" do
      forwarding = Facade::Forwarding.new(
        source: 'testalias',
        domain: 'example.com',
        destinations: ['fwd@example.com']
      )
      allow(mock_api).to receive(:list).and_return([forwarding])

      get emails_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('testalias')
    end

    it "handles Facade::Error gracefully" do
      allow(mock_api).to receive(:list).and_raise(Facade::Error, "API unavailable")

      get emails_path
      expect(response).to have_http_status(:success)
    end

    it "passes all parameter to API" do
      expect(mock_api).to receive(:list).with(all: true).and_return([])

      get emails_path, params: { all: '1' }
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /emails" do
    before { sign_in user }

    it "creates email alias and redirects with notice" do
      post emails_path, params: { address: 'newalias', destinations: 'fwd@example.com' }
      expect(response).to redirect_to(emails_path(created_email: 'newalias@example.com'))
      expect(flash[:notice]).to match(/Email alias created/)
    end

    it "auto-generates alias when address is blank" do
      post emails_path, params: { destinations: 'fwd@example.com' }
      expect(response).to redirect_to(a_string_including(emails_path))
    end

    it "parses multiple comma-separated destinations" do
      expect(mock_api).to receive(:create).with(
        email: 'multi',
        destinations: ['a@example.com', 'b@example.com']
      )

      post emails_path, params: { address: 'multi', destinations: 'a@example.com, b@example.com' }
    end

    it "handles Facade::Error" do
      allow(mock_api).to receive(:create).and_raise(Facade::Error, "Creation failed")

      post emails_path, params: { address: 'fail', destinations: 'fwd@example.com' }
      expect(response).to be_redirect
      expect(flash[:alert]).to match(/Couldn't create email alias/)
    end

    it "returns no_content for JSON format" do
      post emails_path(format: :json), params: { address: 'newalias', destinations: 'fwd@example.com' }
      expect(response).to have_http_status(:no_content)
    end

    it "returns unprocessable_content for JSON on API error" do
      allow(mock_api).to receive(:create).and_raise(Facade::Error, "fail")

      post emails_path(format: :json), params: { address: 'fail', destinations: 'fwd@example.com' }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /emails/:id" do
    before { sign_in user }

    it "destroys email alias and redirects with notice" do
      delete email_path('testalias')
      expect(response).to redirect_to(emails_url)
      expect(flash[:notice]).to match(/Email forwarding removed/)
    end

    it "handles Facade::Error" do
      allow(mock_api).to receive(:delete).and_raise(Facade::Error, "Delete failed")

      delete email_path('testalias')
      expect(response).to be_redirect
      expect(flash[:alert]).to match(/Couldn't remove email forwarding/)
    end

    it "returns no_content for JSON format" do
      delete email_path('testalias', format: :json)
      expect(response).to have_http_status(:no_content)
    end

    it "returns unprocessable_content for JSON on API error" do
      allow(mock_api).to receive(:delete).and_raise(Facade::Error, "fail")

      delete email_path('testalias', format: :json)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
