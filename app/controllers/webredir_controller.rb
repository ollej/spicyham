class WebredirController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :get_domain_server

  def index
    begin
      @webredirs = @domain_server_info.webredirs(email_domain)
    rescue XMLRPC::FaultException => e
      Rails.logger.error { "Gandi::API error domain.webredir.list: #{e.message}" }
      flash[:error] = "Couldn't read webredirs for domain #{email_domain}"
      @webredirs = []
    end
  end
end
