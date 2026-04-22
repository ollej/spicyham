class EmailsController < ApplicationController
  before_action :authenticate_user!
  RANDOM_LENGTH = 16

  # GET /emails
  # GET /emails.json
  def index
    @emails = []
    if user_signed_in? && current_user.api_key.present?
      begin
        @emails = api.list(all: index_params[:all] == "1")
      rescue Facade::Error
        flash[:error] = "Couldn't read emails for domain #{email_domain} using #{current_user.api} API."
      end
    end
    @created_email = index_params[:created_email]
    @email_alias = @created_email.present? ? "" : AliasTemplate.new(index_params[:email], current_user.alias_template).generate
    @destinations = get_destinations(@emails)
    @email_domain = email_domain
  end

  # POST /emails
  # POST /emails.json
  def create
    created_email = build_email(email_alias)
    logger.debug { "Create email alias #{created_email}" }
    destinations = parse_destinations(email_params[:destinations])
    logger.debug { "Destinations: #{destinations.to_sentence}" }

    begin
      api.create(email: email_alias, destinations: destinations)
    rescue Facade::Error => e
      logger.error { "Email forwarding creation error: #{e.message}" }
      respond_to do |format|
        format.html {
          redirect_to emails_path(created_email: created_email),
            alert: "Couldn't create email alias #{created_email} forwarding to #{destinations.to_sentence}. Reason: #{e.message}.",
            status: :see_other }
        format.json { head :unprocessable_content }
      end
      return
    end

    logger.info { "Created email forwarding from #{created_email} to #{destinations.to_sentence}" }

    respond_to do |format|
      format.html {
        redirect_to emails_path(created_email: created_email),
          notice: "Email alias created forwarding from #{created_email} to #{destinations.to_sentence}",
          status: :see_other }
      format.json { head :no_content }
    end
  end

  # DELETE /emails/1
  # DELETE /emails/1.json
  def destroy
    destroyed_email = build_email(email_params[:id])
    begin
      api.delete(email: email_params[:id])
    rescue Facade::Error => e
      logger.error { "Error deleting email alias #{destroyed_email}: #{e.message}" }
      respond_to do |format|
        format.html { redirect_to emails_path, alert: "Couldn't remove email forwarding '#{destroyed_email}': #{e.message}.", status: :see_other }
        format.json { head :unprocessable_content }
      end
      return
    end

    logger.info { "Deleted email: #{destroyed_email}" }

    respond_to do |format|
      format.html { redirect_to emails_url, notice: "Email forwarding removed: #{destroyed_email}", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def email_params
      params.permit(:address, :destinations, :id, :domain)
    end

    def index_params
      params.permit(:email, :all, :created_email)
    end

    def email_alias
      @email_alias ||= email_params[:address].presence || SecureRandom.alphanumeric(RANDOM_LENGTH)
    end

    def build_email(email_alias)
      "#{email_alias}@#{email_domain}"
    end

    def parse_destinations(destinations)
      destinations.split(/[\s,;]+/)
    end

    def get_destinations(emails)
      ["", current_user&.default_forward, find_email_destinations(emails)].flatten.compact.sort
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
