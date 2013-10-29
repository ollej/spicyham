module Gandi
  class DomainException < StandardError; end

  class Domain
    def initialize(server)
      @server = server
    end

    def list(filter = nil)
      filter = filter || { 'sort_by' => 'fqdn' }
      @server.call("domain.list", filter)
    end

    def info(domain)
      @server.call("domain.info", domain)
    end

    def search(domain)
      #domains = [domains] unless domains.kind_of? Array
      puts "domains: #{domain.inspect}"
      result = @server.call("domain.available", [domain], {})
      while result[domain.to_sym] == 'pending' do
        sleep 0.7
        result = @server.call("domain.available", [domain], {})
      end
      result
    end

    def create(domain)
      # Create default params
      params = {}
      @server.call("domain.create", domain, params)
    end

    def webredirs(domain)
      @server.call("domain.webredir.list", domain)
    end
  end
end
