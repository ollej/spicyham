class WebredirController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :get_domain_server

  def index
    @webredirs = @domain_server_info.webredirs(@email_domain)
  end
end
