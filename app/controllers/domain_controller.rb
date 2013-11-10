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
    domains = domain_list(domain_params[:domain])
    logger.info "Searching for domains #{domains}"
    @domain_info = @domain_server.search(domains)
    logger.info "Domain search result: #{@domain_info.inspect}"

    # TODO: Find price for available domains.

    #result = @domain_server.create_contact
    #logger.info "Create contact returned: #{result.inspect}"

    #contacts = @domain_server.contacts
    #logger.info "Contacts: #{contacts.inspect}"

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

    def domain_list(domain)
      default_tlds = %w(com net org se info io it)
      if domain.include? '.'
        domain, default_tld = domain.split('.')
        default_tlds << default_tld unless default_tlds.include? default_tld
      end
      domains = []
      default_tlds.each do |tld|
        domains << "#{domain}.#{tld}"
      end
      domains
    end

    def get_domain_server
      # TODO: Switch to @gandi before release. Support using test automatically in development.
      gandi = Gandi::API.new(ENV['GANDI_TEST_HOST'], ENV['GANDI_TEST_API_KEY'])
      nameservers = ENV['GANDI_DNS'].split(' ')
      @domain_server = Gandi::Domain.new(gandi, ENV['GANDI_CONTACT'], nameservers)
    end
end
