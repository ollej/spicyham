module Facade
  class Migadu
    include ::Migadu

    def initialize(key:, domain:, user: nil)
      @api_user = user
      @api_key = key
      @domain = domain
    end

    def list(all: false, per_page: 50)
      begin
        result = request_and_parse(:get, "domains/#{@domain}/aliases")
        result["address_aliases"].sort_by { |a| a["local_part"] }.map do |a|
          Facade::Forwarding.new(
            source: a["local_part"],
            domain: @domain,
            destinations: a["destinations"]
          )
        end
      rescue ::Migadu::Error => e
        Rails.logger.error { "Migadu error email alias list: #{e}" }
        raise Facade::Error.new(e.message)
      end
    end

    def create(email:, destinations:)
      begin
        request_and_parse(:post, "domains/#{@domain}/aliases", {
          local_part: email,
          destinations: destinations
        })
      rescue ::Migadu::Error => e
        Rails.logger.error { "Migadu error email alias create: #{e}" }
        raise Facade::Error.new(e.message)
      end
    end

    def delete(email:)
      begin
        request_and_parse(:delete, "domains/#{@domain}/aliases/#{email}")
      rescue ::Migadu::Error => e
        Rails.logger.error { "Migadu error email alias delete: #{e}" }
        raise Facade::Error.new(e.message)
      end
    end
  end
end
