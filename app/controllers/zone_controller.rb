require 'gandi_zone'

class ZoneController < ApplicationController
  before_action :get_zone, except: :index

  def index
    @zones = @gandi.call("domain.zone.list")
  end

  def show
    @records = @zone.list(0)
  end

  def delete_record
    @record_id = zone_params[:record].to_i
    if @zone.delete('id' => @record_id)
      message = "Record deleted."
    else
      message = "Couldn't delete record."
    end
    redirect_to zone_show_path(@zone_id), notice: message
  end

  def add_record
    @record = Gandi::Record.new(record_params)
    if @record.valid?
      @zone.add(@record.to_hash)
      @zone.save
      message = "Record successfully added."
    else
      message = "Couldn't save record."
    end
    redirect_to zone_show_path(@zone_id), notice: message
  end

  private
    def zone_params
      params.permit(:zone, :record)
    end

    def record_params
      params.permit(:name, :value, :type, :ttl)
    end

    def get_zone
      @zone_id = zone_params[:zone].to_i
      @zone = Gandi::Zone.new(@gandi, @zone_id)
    end
end
