class TestAPIController < ApplicationController
  before_action :authenticate_user!

  def create
    begin
      api = Facade::API.create(
        api: test_api_params[:api],
        key: test_api_params[:api_key],
        user: test_api_params[:api_user],
        domain: test_api_params[:domain])
      api.list(all: false, per_page: 1)
      success = true
    rescue Facade::Error => e
      Rails.logger.debug { "API test error: #{e.message}" }
      success = false
    end

    respond_to do |format|
      if success
        format.json { head :no_content }
      else
        format.json { head :unprocessable_entity }
      end
    end
  end

  private

  def test_api_params
    params.permit(:api, :api_key, :api_user, :domain)
  end
end
