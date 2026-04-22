require 'rails_helper'

RSpec.describe "Domain", type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:mock_gandi_api) { double("Gandi::API", call: []) }
  let(:mock_domain) do
    double("Gandi::Domain", list: [], info: {}, search: {}, create: {}, price: {}, webredirs: [])
  end

  before do
    allow(Gandi::API).to receive(:new).and_return(mock_gandi_api)
    allow(Gandi::Domain).to receive(:new).and_return(mock_domain)
  end

  describe "unauthenticated" do
    it "redirects from index" do
      get "/domain"
      expect(response).to be_redirect
    end

    it "redirects from show" do
      get "/domain/test"
      expect(response).to be_redirect
    end

    it "redirects from search" do
      get "/domain/search", params: { domain: 'test' }
      expect(response).to be_redirect
    end

    it "redirects from create" do
      post "/domain/create", params: { domain: 'test.com' }
      expect(response).to be_redirect
    end
  end

  describe "non-admin user" do
    before { sign_in user }

    it "returns unauthorized for index" do
      get "/domain"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns unauthorized for show" do
      get "/domain/test"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns unauthorized for search" do
      get "/domain/search", params: { domain: 'test' }
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns unauthorized for create" do
      post "/domain/create", params: { domain: 'test.com' }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "admin user" do
    before { sign_in admin }

    describe "GET /domain" do
      it "renders domain list" do
        get "/domain"
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /domain/:domain" do
      it "renders domain info" do
        allow(mock_domain).to receive(:info).and_return({ 'fqdn' => 'test.com' })

        get "/domain/test"
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /domain/search" do
      it "renders search results as HTML" do
        allow(mock_domain).to receive(:search).and_return({ 'test.com' => 'unavailable' })

        get "/domain/search", params: { domain: 'test' }
        expect(response).to have_http_status(:success)
      end

      it "renders search results as JSON" do
        allow(mock_domain).to receive(:search).and_return({ 'test.com' => 'unavailable' })

        get "/domain/search", params: { domain: 'test', format: :json }
        expect(response).to have_http_status(:success)
      end
    end

    describe "POST /domain/create" do
      it "creates domain and redirects" do
        allow(mock_domain).to receive(:create).and_return({ 'id' => 1 })

        post "/domain/create", params: { domain: 'newdomain.com' }
        expect(response).to be_redirect
      end

      it "handles XMLRPC::FaultException" do
        allow(mock_domain).to receive(:create).and_raise(
          XMLRPC::FaultException.new(500, "[Domain already exists]")
        )

        post "/domain/create", params: { domain: 'existing.com' }
        expect(response).to be_redirect
        expect(flash[:alert]).to match(/Unable to create domain/)
      end

      it "returns unprocessable_entity for JSON on XMLRPC error" do
        allow(mock_domain).to receive(:create).and_raise(
          XMLRPC::FaultException.new(500, "[Error]")
        )

        post "/domain/create", params: { domain: 'fail.com', format: :json }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
