module Facade
  class Glesys
    include ::Glesys

    MODULE = 'email'

    def initialize(key:, domain:, user: nil)
      @api_id = user
      @api_key = key
      @domain = domain
    end

    def list(all: false, per_page: 50)
      begin
        result = request_and_parse("list")
        return result["emailaliases"].map do |emailalias|
          Facade::Forwarding.new(
            source: emailalias["emailalias"],
            domain: @domain,
            destinations: [emailalias["goto"]]
          )
        end
      rescue ::Glesys::Error => e
        Rails.logger.error { "Glesys error email forward list: #{e}" }
        raise Facade::Error.new(e.message)
      end
    end

    def delete(email:)
      begin
        request_and_parse("delete", {
          "email" => "#{email}@#{@domain}"
        })
      rescue ::Glesys::Error => e
        Rails.logger.error { "Glesys error email alias delete: #{e}" }
        raise Facade::Error.new(e.message)
      end
    end

    def create(email:, destinations:)
      begin
        request_and_parse("createalias", {
          "emailalias" => "#{email}@#{@domain}",
          "goto" => destinations.join(',')
        })
      rescue ::Glesys::Error => e
        Rails.logger.error { "Glesys error email alias create: #{e}" }
        raise Facade::Error.new(e.message)
      end
    end
  end
end
