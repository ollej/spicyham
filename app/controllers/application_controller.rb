class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private
    def email_domain
      current_user.domain || ENV['GANDI_MAIL_DOMAIN']
    end

    def authorize_admin!
      raise AuthorizationException unless user_signed_in? && current_user.admin?
    end

    def gandi_api
      @gandi_api ||= Gandi::API.new(ENV['GANDI_HOST'], ENV['GANDI_API_KEY'])
    end

    def get_domain_server
      # TODO: Switch to @gandi before release. Support using test automatically in development.
      gandi_domain_api = Gandi::API.new(ENV['GANDI_DOMAIN_HOST'], ENV['GANDI_DOMAIN_API_KEY'])
      nameservers = ENV['GANDI_NAMESERVERS'].split(' ')
      @domain_server = Gandi::Domain.new(gandi_domain_api, ENV['GANDI_CONTACT'], nameservers)
      @domain_server_info = Gandi::Domain.new(gandi_api, ENV['GANDI_CONTACT'], nameservers)
    end
end
