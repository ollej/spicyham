class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :setup_api, if: :user_signed_in?

  private
    def setup_api
      if current_user.api_key.blank?
        Rails.logger.debug { "Current user has no API key set." }
      end
      @gandi = Gandi::API.new(ENV['GANDI_HOST'], current_user.api_key || '')
    end

    def email_domain
      current_user.domain || ENV['GANDI_MAIL_DOMAIN']
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
