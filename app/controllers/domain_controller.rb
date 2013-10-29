require 'gandi_domain'

class DomainController < ApplicationController
  before_action :authenticate_user!
  before_action :get_domain_server

  def index
    @domains = @domain_server.list
  end

  def show
    @domain = @domain_server.info(domain_params[:domain])
  end

  def search
    @domain_info = @domain_server.search(domain_params[:domain])

    logger.info "Searched for domain #{domain_params[:domain]}: #{@domain_info.inspect}"

    respond_to do |format|
      format.html { render action: "search" }
      format.json { render json: @domain_info }
    end
  end

  def create
    @operation = @domain_server.create(domain_params[:domain])
    # TODO: Handle domain creation error

    logger.info "Created domain #{domain_params[:domain]}: #{@operation}"

    respond_to do |format|
      format.html { redirect_to domain_path, notice: "Created domain #{domain_params[:domain]}." }
      format.json { head :no_content }
    end
  end

  def webredir
    @webredirs = @domain_server.webredirs(@email_domain)
  end

  private
    def domain_params
      params.permit(:domain)
    end

    def get_domain_server
      # Switch to @gandi before release. Support using test automatically in development.
      gandi = Gandi::API.new(ENV['GANDI_TEST_HOST'], ENV['GANDI_TEST_API_KEY'])
      @domain_server = Gandi::Domain.new(gandi)
    end
end
