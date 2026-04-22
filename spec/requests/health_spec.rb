require 'rails_helper'

RSpec.describe "Health check", type: :request do
  it "GET /up returns 200" do
    get "/up"
    expect(response).to have_http_status(:ok)
  end
end
