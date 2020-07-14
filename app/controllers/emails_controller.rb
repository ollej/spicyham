class EmailsController < ApplicationController
  before_action :authenticate_user!
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
    if user_signed_in? && current_user.api_key.present?
      begin
        @emails = api.list(all: params[:all] == "1")
      rescue Facade::Error
        flash[:error] = "Couldn't read emails for domain #{email_domain} using #{current_user.api} API."
        @emails = []
      end
    else
      @emails = []
    end
    @default_email = parse_email_domain(index_params[:email])
    @destinations = get_destinations(@emails)
    @email_domain = email_domain
    @created_email = params[:created_email]
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
    logger.debug { "Destinations: #{destinations.inspect}" }

    begin
      api.create(email: email_params[:address], destinations: destinations)
    rescue Facade::Error => e
      logger.error { "Email forwarding creation error: #{e.message}" }
      respond_to do |format|
        format.html { redirect_to emails_path, alert: "Couldn't create email forwarding '#{destinations}': #{e.message}." }
        format.json { head :unprocessable_entity }
      end
      return
    end

    created_email = "#{email_params[:address]}@#{email_domain}"
    logger.info { "Created email forwarding from #{created_email} to #{destinations.join(', ')}" }

    respond_to do |format|
      format.html { redirect_to emails_path(created_email: created_email), notice: "Email forwarding created: #{created_email} to #{destinations.to_sentence}" }
      format.json { head :no_content }
    end
  end

  # DELETE /emails/1
  # DELETE /emails/1.json
  def destroy
    begin
      api.delete(email: email_params[:id])
    rescue Facade::Error => e
      logger.error { "Email forwarding deletion error: #{e.message}" }
      respond_to do |format|
        format.html { redirect_to emails_path, alert: "Couldn't remove email forwarding '#{email_params[:id]}': #{e.message}." }
        format.json { head :unprocessable_entity }
      end
      return
    end

    destroyed_email = "#{email_params[:id]}@#{email_domain}"
    logger.info { "Deleted email: #{destroyed_email}" }

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

    def index_params
      params.permit(:email)
    end

    def parse_email_domain(email)
      if email
        return email.gsub(/^https?:\/\//, "") # Strip protocol
          .gsub(/#.*$/, "") # Strip all after anchor
          .gsub(/\?.*$/, "") # Strip argument list
          .gsub(/\/.*/, "") # Strip from first slash
          .gsub(/:\d+$/, "") # Strip port
          .gsub(/@/, "") # Strip @
          .gsub(/www\./, "") # Strip sub-domain
          .gsub(/.(?:co|org|ltd|gov|net|me|mil|ac|mod|nhs|nic|plc|sch)(.uk)$/, '\1') # Strip second level TLD in UK
          .gsub(/.(?:com|net|org|edu|gov|asn|id|csiro)(.au)$/, '\1') # Strip second level TLD in AU
          .gsub(/.(?:co|or|priv|ac|gv)(.at)$/, '\1') # Strip second level TLD in AT
          .gsub(/.(ac|co|geek|gen|kiwi|maori|net|org|school|cri|govt|health|iwi|mil|parliament)(.nz)$/, '\1') # Strip second level TLD in NZ
          .gsub(/\.[^.]*$/, "") # Strip TLD
          .gsub(/^.*\./, "") # Leave last sub-domain
      end
    end

    def parse_destinations(destinations)
      destinations.split(/[\s,;]+/)
    end

    def get_destinations(emails)
      ["", find_email_destinations(emails)].flatten.sort
    end

    def find_email_destinations(emails)
      destinations = Set.new
      emails.map do |email|
        destinations.merge(email.destinations)
      end
      destinations.to_a
    end

    def api
      @api ||= Facade::API.create(
        api: current_user.api_name,
        key: current_user.api_key || '',
        user: current_user.api_user,
        domain: email_domain
      )
    end
end
