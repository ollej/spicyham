module Gandi
  class API
    attr_accessor :domain

    def initialize(host, api_key)
      @api_key = api_key
      @server = connect(host || 'rpc.gandi.net')
      Rails.logger.debug { "Setting up Gandi API with key #{@api_key} and host #{host}" }
    end

    def connect(host)
      #net = Net::HTTP.new(host, Net::HTTP.https_default_port)
      #net.use_ssl = true
      #net.verify_mode = OpenSSL::SSL::VERIFY_NONE
      XMLRPC::Client.new(host, '/xmlrpc/', nil, nil, nil, nil, nil, true, 5)
    end

    def call(command, *args)
      Rails.logger.debug { "Gandi API call: #{command} with arguments: #{args.inspect}" }
      @server.call(command, @api_key, *args)
    end

  end

  def self.parse_error(msg)
    /\[(?<error>.*)\]\z/.match(msg)[:error]
  end
end
