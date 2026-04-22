require 'rails_helper'

RSpec.describe "Zone", type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:mock_gandi_api) { double("Gandi::API", call: []) }
  let(:mock_zone) { double("Gandi::Zone", list: [], add: true, delete: true, save: true) }

  before do
    allow(Gandi::API).to receive(:new).and_return(mock_gandi_api)
    allow(Gandi::Zone).to receive(:new).and_return(mock_zone)
  end

  describe "unauthenticated" do
    it "redirects from index" do
      get "/zone"
      expect(response).to be_redirect
    end

    it "redirects from show" do
      get "/zone/123"
      expect(response).to be_redirect
    end

    it "redirects from add_record" do
      post "/zone/123/record", params: { name: 'test', type: 'A', value: '1.2.3.4' }
      expect(response).to be_redirect
    end

    it "redirects from delete_record" do
      delete "/zone/123/record/456"
      expect(response).to be_redirect
    end
  end

  describe "non-admin user" do
    before { sign_in user }

    it "returns unauthorized for index" do
      get "/zone"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns unauthorized for show" do
      get "/zone/123"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns unauthorized for add_record" do
      post "/zone/123/record", params: { name: 'test', type: 'A', value: '1.2.3.4' }
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns unauthorized for delete_record" do
      delete "/zone/123/record/456"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "admin user" do
    before { sign_in admin }

    describe "GET /zone" do
      it "renders zone list" do
        get "/zone"
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /zone/:zone" do
      it "renders zone records" do
        records = [
          { 'name' => 'test', 'type' => 'A', 'value' => '1.2.3.4', 'ttl' => 10800, 'id' => 1 }
        ]
        allow(mock_zone).to receive(:list).and_return(records)

        get "/zone/123"
        expect(response).to have_http_status(:success)
        expect(response.body).to include('test')
      end
    end

    describe "POST /zone/:zone/record" do
      it "adds valid record and redirects" do
        post "/zone/123/record", params: { name: 'test', type: 'A', value: '1.2.3.4', ttl: '10800' }
        expect(response).to redirect_to(zone_show_path(123))
        expect(flash[:notice]).to eq("Record successfully added.")
      end

      it "rejects invalid record and redirects with error" do
        post "/zone/123/record", params: { name: '', type: '', value: '' }
        expect(response).to redirect_to(zone_show_path(123))
        expect(flash[:notice]).to eq("Couldn't save record.")
      end
    end

    describe "DELETE /zone/:zone/record/:record" do
      it "deletes record and redirects" do
        allow(mock_zone).to receive(:delete).and_return(true)

        delete "/zone/123/record/456"
        expect(response).to redirect_to(zone_show_path(123))
        expect(flash[:notice]).to eq("Record deleted.")
      end

      it "handles delete failure" do
        allow(mock_zone).to receive(:delete).and_return(false)

        delete "/zone/123/record/456"
        expect(response).to redirect_to(zone_show_path(123))
        expect(flash[:notice]).to eq("Couldn't delete record.")
      end
    end
  end
end
