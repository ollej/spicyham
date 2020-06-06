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

    def list(opts = {})
      @server.call("domain.forward.list", @domain, opts)
    end

    def create(address, opts)
      @server.call("domain.forward.create", @domain, address, opts)
    end

    def delete(id)
      @server.call("domain.forward.delete", @domain, id)
    end

    def update(address, opts)
      @server.call("domain.forward.update", @domain, address, opts)
    end

    def update_matching(old, new)
      list(items_per_page: 500).each do |email|
        if email["destinations"] == [old]
          update(email["source"], { 'destinations' => [new] })
        end
      end
    end
  end
end
