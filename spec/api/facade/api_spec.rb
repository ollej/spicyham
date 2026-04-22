require 'rails_helper'

RSpec.describe Facade::API do
  before do
    allow(Gandi::API).to receive(:new).and_return(double("Gandi::API"))
    allow(Gandi::Email).to receive(:new).and_return(double("Gandi::Email"))
  end

  describe '.create' do
    it "returns Facade::GandiV5 for 'gandiv5'" do
      result = described_class.create(api: 'gandiv5', key: 'k', domain: 'd')
      expect(result).to be_a(Facade::GandiV5)
    end

    it "returns Facade::Gandi for 'gandixmlrpc'" do
      result = described_class.create(api: 'gandixmlrpc', key: 'k', domain: 'd')
      expect(result).to be_a(Facade::Gandi)
    end

    it "returns Facade::Glesys for 'glesys'" do
      result = described_class.create(api: 'glesys', key: 'k', domain: 'd', user: 'u')
      expect(result).to be_a(Facade::Glesys)
    end

    it "returns Facade::Migadu for 'migadu'" do
      result = described_class.create(api: 'migadu', key: 'k', domain: 'd', user: 'u')
      expect(result).to be_a(Facade::Migadu)
    end

    it "raises Facade::Error for unknown API" do
      expect {
        described_class.create(api: 'unknown', key: 'k', domain: 'd')
      }.to raise_error(Facade::Error, /Unknown API/)
    end
  end
end
