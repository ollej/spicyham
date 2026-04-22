require 'rails_helper'
require_relative '../../../app/api/gandi/zone'

RSpec.describe Gandi::Record do
  describe 'validations' do
    it "is valid with name, type, and value" do
      record = described_class.new(name: 'test', type: 'A', value: '1.2.3.4')
      expect(record).to be_valid
    end

    it "is invalid without name" do
      record = described_class.new(type: 'A', value: '1.2.3.4')
      expect(record).not_to be_valid
    end

    it "is invalid without type" do
      record = described_class.new(name: 'test', value: '1.2.3.4')
      expect(record).not_to be_valid
    end

    it "is invalid without value" do
      record = described_class.new(name: 'test', type: 'A')
      expect(record).not_to be_valid
    end

    it "is invalid with unknown type" do
      record = described_class.new(name: 'test', type: 'INVALID', value: '1.2.3.4')
      expect(record).not_to be_valid
    end

    it "is valid with TTL in range" do
      record = described_class.new(name: 'test', type: 'A', value: '1.2.3.4', ttl: '10800')
      expect(record).to be_valid
    end

    it "is invalid with TTL below minimum" do
      record = described_class.new(name: 'test', type: 'A', value: '1.2.3.4', ttl: '100')
      expect(record).not_to be_valid
    end

    it "is invalid with TTL above maximum" do
      record = described_class.new(name: 'test', type: 'A', value: '1.2.3.4', ttl: '9999999')
      expect(record).not_to be_valid
    end
  end

  describe '#to_hash' do
    it "returns hash of attributes" do
      record = described_class.new(name: 'test', type: 'A', value: '1.2.3.4', ttl: '10800')
      hash = record.to_hash
      expect(hash[:name]).to eq('test')
      expect(hash[:type]).to eq('A')
      expect(hash[:value]).to eq('1.2.3.4')
      expect(hash[:ttl]).to eq(10800)
    end
  end
end

RSpec.describe Gandi::TYPE do
  describe '.all' do
    it "returns all four DNS record types" do
      expect(described_class.all).to contain_exactly('A', 'CNAME', 'MX', 'TXT')
    end
  end

  describe '.exists' do
    it "returns true for valid types" do
      expect(described_class.exists('A')).to be true
    end

    it "returns false for invalid types" do
      expect(described_class.exists('INVALID')).to be false
    end
  end
end
