require 'gandi_email'

class EmailsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_email_server
  #before_action :set_email, only: [:show, :edit, :update, :destroy]
  # TODO: Create Email class instead of calling @gandi directly.
  # TODO: Support editing forwards for other domains.

  # GET /emails
  # GET /emails.json
  def index

    #server.call("domain.forward.count", apikey, 'mydomain.net')
    #1
    #[{'destinations' => ['stephanie@example.com'], 'source' => 'admin'}]

    #server.call("domain.forward.create", apikey, 'mydomain.net', 'admin',
    #  {'destinations' => ['stephanie@example.com']})
    #{'destinations' => ['stephanie@example.com'], 'source': 'admin'}

    #server.call("domain.forward.update", apikey, 'mydomain.net', 'admin',
    #  {'destinations' => ['stephanie@example.com', 'steph@example.com']})
    #{'destinations' => ['stephanie@example.com', 'steph@example.com'],
    #... 'source' => 'admin'}

    #server.call("domain.forward.delete", apikey, 'mydomain.net', 'admin')
    #True

    #@emails = Email.all
    #puts "GANDI API Version", @server.call("domain.info", @apikey, 'ollej.com')

    #@emails = server.call("domain.forward.list", @apikey, @mail_domain)
    # TODO: Add template helper to select most popular email in destination list.
    @email = Email.new
    @emails = get_emails
    @destinations = get_destinations(@emails)
  end

  # GET /emails/1
  # GET /emails/1.json
  def show
  end

  # GET /emails/new
  def new
    @email = Email.new
  end

  # GET /emails/1/edit
  def edit
  end

  # POST /emails
  # POST /emails.json
  def create
    #@email = Email.new(email_params)
    destinations = parse_destinations(email_params[:destinations])
    logger.debug "Destinations: #{destinations.inspect}"

    begin
      @email_server.create(email_params[:address], { 'destinations' => destinations })
    rescue XMLRPC::FaultException => e
      respond_to do |format|
        error = Gandi::parse_error(e.message)
        logger.debug "Email forwarding creation error: #{error}"
        format.html { redirect_to emails_path, alert: "Couldn't create email forwarding '#{destinations}': #{error}." }
        format.json { head :no_content, status: :unprocessable_entity }
      end
      return
    end

    created_email = "#{email_params[:address]}@#{@email_domain}"
    logger.info "Created email forwarding from #{created_email} to #{destinations.join(', ')}"

    respond_to do |format|
      format.html { redirect_to emails_url, notice: "Email forwarding created: #{created_email} to #{destinations.to_sentence}" }
      format.json { head :no_content }
    end
  end

  # DELETE /emails/1
  # DELETE /emails/1.json
  def destroy
    #@email.destroy
    @email_server.delete(email_params[:id])

    destroyed_email = "#{email_params[:id]}@#{@email_domain}"
    logger.info "Deleted email: #{destroyed_email}"

    respond_to do |format|
      format.html { redirect_to emails_url, notice: "Email forwarding removed: #{destroyed_email}" }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_email
      @email = Email.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def email_params
      params.permit(:address, :destinations, :id, :domain)
    end

    def parse_destinations(destinations)
      destinations.split(/[\s,;]+/)
    end

    def find_email_destinations(emails)
      destinations = Set.new
      emails.map do |email|
        destinations.merge(email['destinations'])
      end
      destinations.to_a
    end

    def get_email_server
      domain = email_params[:domain] || ENV['GANDI_MAIL_DOMAIN']
      @email_server = Gandi::Email.new(@gandi, domain)
    end

    def get_emails
      opts = {
        items_per_page: 20,
        sort_by: 'source'
      }
      if params[:all].present?
        opts[:items_per_page] = 500
      end
      @email_server.list(opts)
    end

    def get_destinations(emails)
      ["", find_email_destinations(emails)].flatten.sort
    end
end
