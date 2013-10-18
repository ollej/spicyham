#require 'xmlrpc/client'
require 'xml/libxml/xmlrpc'
require 'net/http'

class EmailsController < ApplicationController
  #before_action :set_email, only: [:show, :edit, :update, :destroy]
  before_action :setup_api

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
    @email = Email.new
    @emails = api_call("domain.forward.list")
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
    api_call("domain.forward.create", email_params[:address],
       { 'destinations' => parse_destinations(email_params[:destinations]) } )

    respond_to do |format|
      format.html { redirect_to emails_url }
      format.json { head :no_content }
    end
  end

  # PATCH/PUT /emails/1
  # PATCH/PUT /emails/1.json
  def update
    respond_to do |format|
      if @email.update(email_params)
        format.html { redirect_to @email, notice: 'Email was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @email.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /emails/1
  # DELETE /emails/1.json
  def destroy
    #@email.destroy
    api_call("domain.forward.delete", params[:id])
    respond_to do |format|
      format.html { redirect_to emails_url }
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
      params.require(:email).permit(:address, :destinations)
    end

    def setup_api
      @apikey = ENV['GANDI_API_KEY']
      @mail_domain = ENV['GANDI_MAIL_DOMAIN']
      net = Net::HTTP.new("rpc.gandi.net", Net::HTTP.https_default_port)
      net.use_ssl = true
      net.verify_mode = OpenSSL::SSL::VERIFY_NONE
      @server = XML::XMLRPC::Client.new(net, "/xmlrpc/")
      #@server = XMLRPC::Client.new2('https://rpc.gandi.net/xmlrpc/')
      #@server = XMLRPC::Client.new2('https://rpc.ote.gandi.net/xmlrpc/')
      # Remove line 505/506 in lib/ruby/2.0.0/xmlrpc/client.rb
      #elsif expected != "<unknown>" and expected.to_i != data.bytesize and resp["Transfer-Encoding"].nil?
      #  raise "Wrong size. Was #{data.bytesize}, should be #{expected}"
    end

    def api_call(command, *args)
      parser = @server.call(command, @apikey, @mail_domain, *args)
      parser.params.first
    end

    def parse_destinations(destinations)
      destinations.split(/[\s,;]+/)
    end
end
