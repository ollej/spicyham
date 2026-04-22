require 'rails_helper'

RSpec.describe "TestAPI", type: :request do
  let(:user) { create(:user) }

  describe "unauthenticated" do
    it "redirects from create" do
      post "/test_api"
      expect(response).to be_redirect
    end
  end

  describe "authenticated" do
    before { sign_in user }

    it "returns no_content on successful API test" do
      mock_api = double("Facade::API", list: [])
      allow(Facade::API).to receive(:create).and_return(mock_api)

      post "/test_api", params: { api: 'gandiv5', api_key: 'key', domain: 'test.com' }, as: :json
      expect(response).to have_http_status(:no_content)
    end

    it "returns unprocessable_content on Facade::Error" do
      mock_api = double("Facade::API")
      allow(mock_api).to receive(:list).and_raise(Facade::Error, "Auth failed")
      allow(Facade::API).to receive(:create).and_return(mock_api)

      post "/test_api", params: { api: 'gandiv5', api_key: 'bad', domain: 'test.com' }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
