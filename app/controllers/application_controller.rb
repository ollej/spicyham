require 'gandi_api'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :setup_api

  private
    def setup_api
      @email_domain = ENV['GANDI_MAIL_DOMAIN']
      @gandi = Gandi::API.new(ENV['GANDI_HOST'], ENV['GANDI_API_KEY'])
    end
end
