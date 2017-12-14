require 'gandi_domain'

class DomainController < ApplicationController
  before_action :authenticate_user!
  before_action :get_domain_server

  def index
    @domains = @domain_server.list + @domain_server_info.list
  end

  def show
    @domain = @domain_server.info(domain_params[:domain])
  end

  def search
    domains = domain_list(domain_params[:domain])
    logger.debug "Searching for domains #{domains}"
    @domain_info = @domain_server.search(domains)
    logger.debug "Domain search result: #{@domain_info.inspect}"

    add_prices(@domain_info)
    # TODO: Find price for available domains.
    # TODO: Return result directly based on param, to allow ajax updates of search.

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
    begin
      @operation = @domain_server.create(domain_params[:domain])
    rescue XMLRPC::FaultException => e
      respond_to do |format|
        error = Gandi::parse_error(e.message)
        logger.debug "Unable to create domain #{domain_params[:domain]}: #{error}"
        format.html { redirect_to domain_path, alert: "Unable to create domain '#{domain_params[:domain]}': #{error}." }
        format.json { head :no_content, status: :unprocessable_entity }
      end
      return
    end

    logger.info "Created domain #{domain_params[:domain]}: #{@operation}"
    # TODO: Add action to find if create operation is done.
    # TODO: Store operation id in db

    respond_to do |format|
      format.html { redirect_to domain_path, notice: "Created domain #{domain_params[:domain]}." }
      format.json { head :no_content }
    end
  end

  def webredir
    @webredirs = @domain_server_info.webredirs(@email_domain)
  end

  private
    def domain_params
      params.permit(:domain)
    end

    def search_tlds
      tlds = ENV.fetch('SEARCH_TLDS', %w(com net org se info io it))
      tlds = tlds.split(' ') if tlds.kind_of? String
      tlds
    end

    def domain_list(domain)
      default_tlds = search_tlds
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
      gandi = Gandi::API.new(ENV['GANDI_DOMAIN_HOST'], ENV['GANDI_DOMAIN_API_KEY'])
      nameservers = ENV['GANDI_NAMESERVERS'].split(' ')
      @domain_server = Gandi::Domain.new(gandi, ENV['GANDI_CONTACT'], nameservers)
      @domain_server_info = Gandi::Domain.new(@gandi, ENV['GANDI_CONTACT'], nameservers)
    end

    def add_prices(domains)
      domains.each do |domain, status|
        if status == "available"
          price = @domain_server.price(domain)
          logger.info "Price of #{domain}: #{price.inspect}"
          domains[domain] = price
        end
      end
    end
end
