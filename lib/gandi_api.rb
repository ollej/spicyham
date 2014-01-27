require 'xml/libxml/xmlrpc'
require 'net/http'

module Gandi
  mattr_accessor :logger

  class API
    attr_accessor :domain

    def initialize(host, api_key)
      @api_key = api_key
      @server = connect(host || "rpc.gandi.net")
      Gandi.logger.debug("Setting up Gandi API with key #{@api_key} and host #{host}")
    end

    def connect(host)
      net = Net::HTTP.new(host, Net::HTTP.https_default_port)
      net.use_ssl = true
      net.verify_mode = OpenSSL::SSL::VERIFY_NONE
      XML::XMLRPC::Client.new(net, "/xmlrpc/")
    end

    def call(command, *args)
      Gandi.logger.debug("Gandi API call: #{command} with arguments: #{args.inspect}")
      parser = @server.call(command, @api_key, *args)
      parser.params.first
    end

  end

  def self.parse_error(msg)
    /\[(?<error>.*)\]\z/.match(msg)[:error]
  end
end
