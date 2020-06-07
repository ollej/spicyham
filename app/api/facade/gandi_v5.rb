module Facade
  class GandiV5
    def initialize(key:, domain:, user: nil)
      ::GandiV5.api_key = key
      @domain = domain
    end

    def list(all: false)
      begin
        Rails.logger.debug { "Listing forwards with all: #{all} -> #{all ? (1..) : 1}" }
        params = {
          sort_by: 'source',
          per_page: 50
        }
        params[:page] = 1 unless all
        return ::GandiV5::Email::Forward.list(@domain, **params).map do |forward|
          Facade::Forwarding.new(source: forward.source, domain: forward.fqdn, destinations: forward.destinations)
        end
      rescue RestClient::Unauthorized, RestClient::Forbidden, GandiV5::Error, JSON::ParserError => e
        Rails.logger.error { "GandiV5 error email forward list: #{e}" }
        raise Facade::Error.new(e.message)
      end
    end

    def delete(email:)
      begin
        ::GandiV5::Email::Forward.new(fqdn: @domain, source: email).delete
      rescue RestClient::Unauthorized, RestClient::Forbidden, GandiV5::Error, JSON::ParserError => e
        Rails.logger.error { "GandiV5 error email forward delete: #{e.message}" }
        raise Facade::Error.new(e.message)
      end
    end

    def create(email:, destinations:)
      Rails.logger.debug { "destinations: #{destinations.inspect}" }
      begin
        ::GandiV5::Email::Forward.create(@domain, email, *destinations)
      rescue RestClient::Unauthorized, RestClient::Forbidden, GandiV5::Error, JSON::ParserError => e
        Rails.logger.error { "GandiV5 error email forward create: #{e.message}" }
        raise Facade::Error.new(e.message)
      end
    end
  end
end
