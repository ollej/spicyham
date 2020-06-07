module Facade
  class Forwarding
    attr_accessor :source, :destinations, :domain

    def initialize(source:, domain:, destinations: [])
      @source = source
      @domain = domain
      @destinations = destinations
    end

    def destinations_string
      @destinations.to_sentence
    end
  end
end
