module Gandi
  class DomainException < StandardError; end

  class Domain
    def initialize(server, contact, nameservers)
      @server = server
      @contact = contact
      @nameservers = nameservers
    end

    def contacts
      @server.call("contact.list")
    end

    def nameservers(domain, nameservers)
      @server.call("domain.nameservers.set", domain, nameservers)
    end

    def create_contact
      contact_spec = {
        given: 'First Name',
        family: 'Last Name',
        email: 'example@example.com',
        streetaddr: 'My Street Address',
        zip: '75011',
        city: 'Paris',
        country: 'FR',
        phone:'+33.123456789',
        type: 0,
        password: 'xxxxxxxx'
      }
      @server.call("contact.create", contact_spec)
    end

    def catalog(opts, currency = 'EUR', grid='A')
      @server.call("catalog.list", opts, currency, grid)
    end

    def price(domain, *args)
      product_spec = {
        product: { type: 'domain', description: domain.to_s },
        'action' => { 'name' => 'create', 'duration' =>  1 }
      }
      Gandi.logger.debug { "Domain price lookup: #{product_spec.inspect}" }
      result = catalog(product_spec, *args)
      Gandi.logger.debug { "Price result: #{result.first.inspect}" }
      result.first[:unit_price].first
    end

    def list(filter = nil)
      filter = filter || { 'sort_by' => 'fqdn' }
      @server.call("domain.list", filter)
    end

    def info(domain)
      @server.call("domain.info", domain)
    end

    def search(domains)
      #domains = [domains] unless domains.kind_of? Array
      Gandi.logger.debug { "Searching domains: #{domains.inspect}" }
      result = @server.call("domain.available", domains, {})
      while still_pending(result) do
        sleep 0.7
        result = @server.call("domain.available", domains, {})
      end
      result
    end

    def create(domain)
      # Create default params
      @contact = contact
      Gandi.logger.debug { "Setting Gandi contact: #{@contact}" }
      domain_spec = {
        owner: @contact,
        admin: @contact,
        bill: @contact,
        tech: @contact,
        nameservers: @nameservers,
        accept_contract: true,
        duration: 1
      }
      @server.call("domain.create", domain, domain_spec)
    end

    def webredirs(domain)
      @server.call("domain.webredir.list", domain)
    end

    def contact
      if Rails.env == "development"
        result = create_contact
        Gandi.logger.debug { "Create contact returned: #{result.inspect}" }
        contact = result[:handle]
      else
        contact = ENV['GANDI_CONTACT_OWNER']
      end
      contact
    end

    private
      def still_pending(result)
        result.values.include? 'pending'
      end
  end
end
