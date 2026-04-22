require 'rails_helper'
require_relative '../../../app/api/gandi/zone'

RSpec.describe Gandi::Zone do
  let(:server) { double("Gandi::API") }
  let(:zone) { described_class.new(server, 123) }

  describe '#list' do
    it "calls server with domain.zone.record.list" do
      expect(server).to receive(:call).with('domain.zone.record.list', 123, 0).and_return([])
      zone.list(0)
    end
  end

  describe '#add' do
    it "appends record to internal records array" do
      record = { name: 'test', type: 'A', value: '1.2.3.4' }
      zone.add(record)
      expect(zone.records).to include(record)
    end
  end

  describe '#create_new_version' do
    it "calls server to create new zone version" do
      expect(server).to receive(:call).with('domain.zone.version.new', 123).and_return(2)
      zone.create_new_version
    end
  end

  describe '#save' do
    it "does nothing when no records to save" do
      expect(server).not_to receive(:call)
      zone.save
    end

    it "creates version, adds records, and activates" do
      record = double("Record", to_hash: { name: 'test', type: 'A', value: '1.2.3.4' })
      zone.add(record)

      expect(server).to receive(:call).with('domain.zone.version.new', 123).and_return(2)
      expect(server).to receive(:call).with('domain.zone.record.add', 123, 2, record.to_hash).and_return({})
      expect(server).to receive(:call).with('domain.zone.version.set', 123, 2).and_return(true)

      zone.save
      expect(zone.records).to be_empty
    end
  end

  describe '#delete' do
    it "deletes matching records and activates on success" do
      filter = { 'id' => 42 }
      matching_records = [{ id: 42, name: 'test', type: 'A', value: '1.2.3.4' }]

      expect(server).to receive(:call).with('domain.zone.version.new', 123).and_return(2)
      expect(server).to receive(:call).with('domain.zone.record.list', 123, 0, filter).and_return(matching_records)
      expect(server).to receive(:call).with('domain.zone.record.delete', 123, 2, anything).and_return(1)
      expect(server).to receive(:call).with('domain.zone.version.set', 123, 2).and_return(true)

      expect(zone.delete(filter)).to be true
    end

    it "rolls back version on delete failure" do
      filter = { 'id' => 42 }
      matching_records = [{ id: 42, name: 'test', type: 'A', value: '1.2.3.4' }]

      expect(server).to receive(:call).with('domain.zone.version.new', 123).and_return(2)
      expect(server).to receive(:call).with('domain.zone.record.list', 123, 0, filter).and_return(matching_records)
      expect(server).to receive(:call).with('domain.zone.record.delete', 123, 2, anything).and_return(0)
      expect(server).to receive(:call).with('domain.zone.version.delete', 123, 2).and_return(true)

      expect(zone.delete(filter)).to be false
    end
  end
end
