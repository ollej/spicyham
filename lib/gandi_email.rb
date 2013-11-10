module Gandi
  class EmailException < StandardError; end

  class Email
    def initialize(server, domain)
      @server = server
      @domain = domain
    end

    def call_domain(command, *args)
      parser = @server.call("domain.#{command}", @api_key, @domain, *args)
      parser.params.first
    end

    def list
      @server.call("domain.forward.list", @domain)
    end

    def create(address, opts)
      @server.call("domain.forward.create", @domain, address, opts)
    end

    def delete(id)
      @server.call("domain.forward.delete", @domain, id)
    end
  end
end
