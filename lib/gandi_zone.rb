module Gandi
  class ZoneException < StandardError; end

  module TYPE
    A = 'A'
    CNAME = 'CNAME'
    MX = 'MX'

    def self.all
      [Gandi::TYPE::A, Gandi::TYPE::CNAME, Gandi::TYPE::MX]
    end

    def self.exists(type)
      self.all.include? type
    end
  end

  class Zone
    attr_reader :zone, :domain

    def initialize(server, zone_id)
      @server = server
      @zone_id = zone_id.to_i
      @version = @server.call("domain.zone.version.new", @zone_id)
    end

    def list(version = nil)
      version ||= @version
      @server.call("domain.zone.record.list", @zone_id, version)
    end

    def add(record)
      # TODO: Check that record doesn't exist
      # TODO: Raise exception on failure
      @server.call("domain.zone.record.add", @zone_id, @version, record.to_hash)
    end

    def save
      # TODO: Raise exception on failure
      unless @server.call("domain.zone.version.set", @zone_id, @version)
        raise Gandi::ZoneException.new "Couldn't set new version."
      end
    end
  end

  class Record
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    attr_accessor :type, :name, :value, :ttl

    validates_presence_of :type, :name, :value
    validates_format_of :name, with: /\A(?:(?!-)[-_*@a-zA-Z0-9]{1,63}(?<!-)(\.|$))*(?<!\.)\z/
    validates_format_of :value, with: /\A(?:(?!-)[-_@a-zA-Z0-9]{1,63}(?<!-)(\.|$))*\z/
    validates_length_of :value, maximum: 1024
    validates_inclusion_of :type, in: Gandi::TYPE.all
    validates_numericality_of :ttl, allow_nil: true,
      greater_than: 5.minutes, less_than: 30.days

    def initialize(attributes = {})
      @attributes = attributes
      attributes.each do |name, value|
        send("#{name}=", value)
      end
      # TODO: Validate type
      # TODO: Validate value based on type
      # ^(?:(?!-)[-_@a-zA-Z0-9]{1,63}(?<!-)(\.|$))*$
      # TODO: Validate ttl
      # TODO: Validate name
    end

    def to_hash
      @attributes
    end

    def adsf

      hash = Hash.new
      instance_variables.each do |key|
        value = instance_variable_get(key)
        unless value.nil?
          key = key.to_s[1..-1].to_sym
          hash[key] = value
        end
      end
      hash
    end

    def persisted?
      false
    end
  end

end
