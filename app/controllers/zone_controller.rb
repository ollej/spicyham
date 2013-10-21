require 'gandi_zone'

class ZoneController < ApplicationController
  def index
    @zones = @gandi.call("domain.zone.list")
  end

  def show
    @zone_id = zone_params[:zone].to_i
    @records = @gandi.call("domain.zone.record.list", @zone_id, 0)
  end

  def add_record
    # clone zone
    zone = Gandi::Zone.new(@gandi, zone_params[:zone])

    # add record
    @record = Gandi::Record.new(record_params)
    if @record.valid?
      puts @record.to_hash
      zone.add(@record.to_hash)
      zone.save
    end
  end

  private
    def zone_params
      params.permit(:zone)
    end

    def record_params
      params.permit(:name, :value, :type, :ttl)
    end
end
