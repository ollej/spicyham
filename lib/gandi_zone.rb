module Gandi
  class ZoneException < StandardError; end

  module TYPE
    A = 'A'
    CNAME = 'CNAME'
    MX = 'MX'
    TXT = 'TXT'

    def self.all
      [Gandi::TYPE::A, Gandi::TYPE::CNAME, Gandi::TYPE::MX, Gandi::TYPE::TXT]
    end

    def self.exists(type)
      self.all.include? type
    end
  end

  class Zone
    attr_reader :zone, :records

    def initialize(server, zone_id)
      @server = server
      @zone_id = zone_id.to_i
      @records = []
    end

    def list(version = nil, *args)
      version ||= @version
      @server.call("domain.zone.record.list", @zone_id, version, *args)
    end

    def add(record)
      # TODO: Check that record doesn't exist
      # TODO: Raise exception on failure
      @records << record
    end

    def delete(filter)
      create_new_version
      # FIXME: Delete on id doesn't work.
      deleted = 0
      records = list(0, filter)
      records.each do |record|
        record.delete(:id)
        record.stringify_keys
        deleted += @server.call("domain.zone.record.delete", @zone_id, @version, record)
      end
      if deleted == records.size
        activate
        return true
      else
        delete_version(@version)
        return false
      end
    end

    def save(records = nil)
      # TODO: Raise exception on any failure
      @records += records unless records.nil?
      if @records.size > 0
        create_new_version
        @records.each do |record|
          new_record = @server.call("domain.zone.record.add", @zone_id, @version, record.to_hash)
          if new_record.nil?
            raise Gandi::ZoneException.new "Couldn't create a record."
          end
        end
        activate
        @records = []
      end
    end

    def create_new_version
      @version = @server.call("domain.zone.version.new", @zone_id)
    end

    def delete_version(version)
      @server.call("domain.zone.version.new", @zone_id, version)
    end

    def activate
      unless @server.call("domain.zone.version.set", @zone_id, @version)
        raise Gandi::ZoneException.new "Couldn't set new version."
      end
    end
  end

  class Record
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    @@attribs = [:type, :name, :value, :ttl]

    attr_accessor(*@@attribs)

    validates_presence_of :type, :name, :value
    validates_format_of :name, with: /\A(?:(?!-)[-_*@a-zA-Z0-9]{1,63}(?<!-)(\.|$))*(?<!\.)\z/
    validates_format_of :value, with: /\A(?:(?!-)[-_@a-zA-Z0-9]{1,63}(?<!-)(\.|$))*\z/
    validates_length_of :value, maximum: 1024
    validates_inclusion_of :type, in: Gandi::TYPE.all
    validates_numericality_of :ttl, allow_nil: true,
      greater_than: 5.minutes, less_than: 30.days
    # TODO: Validate value based on type (A should be IP, CNAME end with .)

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value) unless value.nil? or value == ""
      end
    end

    def to_hash
      Hash[@@attribs.map {|key| [key, send(key)] if send(key)}]
    end

    def persisted?
      false
    end
  end

end
