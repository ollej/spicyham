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
      Rails.logger.debug { "Listing email on #{@domain}" }
      @server.call("domain.forward.list", @domain, opts)
    end

    def create(address, opts)
      Rails.logger.debug { "Creating email on #{@domain} with #{address}" }
      @server.call("domain.forward.create", @domain, address, opts)
    end

    def delete(id)
      Rails.logger.debug { "Deleting email on #{@domain} with #{id}" }
      @server.call("domain.forward.delete", @domain, id)
    end

    def update(address, opts)
      Rails.logger.debug { "Updating email on #{@domain} with #{address}" }
      @server.call("domain.forward.update", @domain, address, opts)
    end

    def update_matching(old, new)
      Rails.logger.debug { "Updating email forwardings from #{old} to #{new}" }
      list(items_per_page: 500).each do |email|
        if email["destinations"] == [old]
          update(email["source"], { 'destinations' => [new] })
        end
      end
    end
  end
end
