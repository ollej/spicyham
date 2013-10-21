require 'gandi_api'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :setup_api

  private
    def setup_api
      @gandi = Gandi::API.new(ENV['GANDI_API_KEY'], ENV['GANDI_MAIL_DOMAIN'])
    end
end
