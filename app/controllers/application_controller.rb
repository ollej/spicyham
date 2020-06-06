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

    def authorize_admin!
      raise AuthorizationException unless user_signed_in? && current_user.admin?
    end

    def get_domain_server
      # TODO: Switch to @gandi before release. Support using test automatically in development.
      gandi = Gandi::API.new(ENV['GANDI_DOMAIN_HOST'], ENV['GANDI_DOMAIN_API_KEY'])
      nameservers = ENV['GANDI_NAMESERVERS'].split(' ')
      @domain_server = Gandi::Domain.new(gandi, ENV['GANDI_CONTACT'], nameservers)
      @domain_server_info = Gandi::Domain.new(@gandi, ENV['GANDI_CONTACT'], nameservers)
    end
end
