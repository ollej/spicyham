require 'xml/libxml/xmlrpc'
require 'net/http'

module Gandi
  class API
    attr_accessor :domain

    def initialize(api_key, domain)
      @api_key = api_key
      @domain = domain
      @server = connect("rpc.gandi.net" || ENV['GANDI_HOST'])
    end

    def connect(host)
      net = Net::HTTP.new(host, Net::HTTP.https_default_port)
      net.use_ssl = true
      net.verify_mode = OpenSSL::SSL::VERIFY_NONE
      XML::XMLRPC::Client.new(net, "/xmlrpc/")
    end

    def call_domain(command, *args)
      parser = @server.call("domain.#{command}", @api_key, @domain, *args)
      parser.params.first
    end

    def call(command, *args)
      parser = @server.call(command, @api_key, *args)
      parser.params.first
    end
  end
end
