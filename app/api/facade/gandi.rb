module Facade
  class Gandi
    def initialize(key:, domain:, user: nil)
      @gandi = Gandi::API.new(ENV['GANDI_HOST'], key)
      @email_server = Gandi::Email.new(@gandi, domain)
      @domain = domain
    end

    def list(all: false)
      begin
        return @email_server.list({
          items_per_page: all ? 500 : 20,
          sort_by: 'source'
        }).map do |email|
          Facade::Forwarding.new(source: email['source'], domain: @domain, destinations: email['destinations'])
        end
      rescue XMLRPC::FaultException => e
        Rails.logger.error { "Gandi::API error domain.email.list: #{e.message}" }
        error = Gandi::parse_error(e.message)
        raise Facade::Error.new(error)
      end
    end

    def delete(email:)
      begin
        @email_server.delete(email)
      rescue XMLRPC::FaultException => e
        Rails.logger.error { "Gandi::API error domain.email.delete: #{e.message}" }
        error = Gandi::parse_error(e.message)
        raise Facade::Error.new(error)
      end
    end

    def create(email:, destinations:)
      begin
        @email_server.create(email, { 'destinations' => destinations })
      rescue XMLRPC::FaultException => e
        Rails.logger.error { "Gandi::API error domain.email.create: #{e.message}" }
        error = Gandi::parse_error(e.message)
        raise Facade::Error.new(error)
      end
    end
  end
end
