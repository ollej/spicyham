require 'xml/libxml/xmlrpc'
require 'net/http'

module Gandi
  class API
    attr_accessor :domain

    def initialize(host, api_key)
      @api_key = api_key
      @server = connect(host || "rpc.gandi.net")
    end

    def connect(host)
      net = Net::HTTP.new(host, Net::HTTP.https_default_port)
      net.use_ssl = true
      net.verify_mode = OpenSSL::SSL::VERIFY_NONE
      XML::XMLRPC::Client.new(net, "/xmlrpc/")
    end

    def call(command, *args)
      parser = @server.call(command, @api_key, *args)
      parser.params.first
    end

  end

  def self.parse_error(msg)
    /\[(?<error>.*)\]\z/.match(msg)[:error]
  end
end
