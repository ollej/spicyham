require 'rails_helper'

RSpec.describe "Pages", type: :request do
  describe "GET /" do
    it "renders home page for unauthenticated user" do
      get root_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Email alias creation")
    end

    it "shows emails index for authenticated user" do
      sign_in create(:user)
      mock_api = double("Facade::API", list: [])
      allow(Facade::API).to receive(:create).and_return(mock_api)

      get root_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Email forwards")
    end

    it "includes feature descriptions" do
      get root_path
      expect(response.body).to include("Increased security")
      expect(response.body).to include("Spam protection")
      expect(response.body).to include("Improved privacy")
    end

    it "includes supported email providers" do
      get root_path
      expect(response.body).to include("Migadu")
      expect(response.body).to include("Gandi")
      expect(response.body).to include("Glesys")
    end
  end
end
