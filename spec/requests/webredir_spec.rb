require 'rails_helper'

RSpec.describe "Webredir", type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:mock_gandi_api) { double("Gandi::API", call: []) }
  let(:mock_domain) do
    double("Gandi::Domain", list: [], webredirs: [])
  end

  before do
    allow(Gandi::API).to receive(:new).and_return(mock_gandi_api)
    allow(Gandi::Domain).to receive(:new).and_return(mock_domain)
  end

  describe "unauthenticated" do
    it "redirects from index" do
      get "/webredir"
      expect(response).to be_redirect
    end
  end

  describe "non-admin user" do
    before { sign_in user }

    it "returns unauthorized" do
      get "/webredir"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "admin user" do
    before { sign_in admin }

    it "renders webredir list" do
      get "/webredir"
      expect(response).to have_http_status(:success)
    end

    it "displays web redirections" do
      webredirs = [{ 'host' => 'www', 'type' => '301', 'url' => 'https://example.com' }]
      allow(mock_domain).to receive(:webredirs).and_return(webredirs)

      get "/webredir"
      expect(response).to have_http_status(:success)
      expect(response.body).to include('www')
    end

    it "handles XMLRPC::FaultException" do
      allow(mock_domain).to receive(:webredirs).and_raise(
        XMLRPC::FaultException.new(500, "Error")
      )

      get "/webredir"
      expect(response).to have_http_status(:success)
    end
  end
end
