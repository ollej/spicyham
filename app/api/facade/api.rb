module Facade
  class API
    GANDI_V5 = 'gandiv5'
    GANDI_XMLRPC = 'gandixmlrpc'

    def self.create(api:, key:, domain:, user: nil)
      if api == GANDI_V5
        Facade::GandiV5.new(key: key, domain: domain)
      elsif api == GANDI_XMLRPC
        Facade::Gandi.new(key: key, domain: domain)
      else
        raise Facade::Error.new("Unknown API: #{api}")
      end
    end
  end
end
