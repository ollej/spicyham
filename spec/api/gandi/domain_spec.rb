require 'rails_helper'

RSpec.describe Gandi::Domain do
  let(:server) { double("Gandi::API") }
  let(:domain) { described_class.new(server, 'TEST-CONTACT', ['ns1.test.net', 'ns2.test.net']) }

  describe '#list' do
    it "calls server with domain.list" do
      expect(server).to receive(:call).with('domain.list', { 'sort_by' => 'fqdn' }).and_return([])
      domain.list
    end
  end

  describe '#info' do
    it "calls server with domain.info and domain name" do
      expect(server).to receive(:call).with('domain.info', 'example.com').and_return({})
      domain.info('example.com')
    end
  end

  describe '#webredirs' do
    it "calls server with domain.webredir.list" do
      expect(server).to receive(:call).with('domain.webredir.list', 'example.com').and_return([])
      domain.webredirs('example.com')
    end
  end

  describe '#search' do
    it "returns results when no pending domains" do
      results = { 'test.com' => 'available', 'test.net' => 'unavailable' }
      allow(server).to receive(:call).with('domain.available', ['test.com', 'test.net'], {}).and_return(results)

      expect(domain.search(['test.com', 'test.net'])).to eq(results)
    end
  end

  describe '#price' do
    it "extracts unit_price from catalog result" do
      catalog_result = [{ 'unit_price' => [{ 'price' => 12.50, 'currency' => 'EUR' }] }]
      allow(server).to receive(:call).and_return(catalog_result)

      expect(domain.price('test.com')).to eq({ 'price' => 12.50, 'currency' => 'EUR' })
    end
  end

  describe '#create' do
    it "calls server with domain spec including contact and nameservers" do
      ENV['GANDI_CONTACT_OWNER'] = 'OWNER-HANDLE'
      expect(server).to receive(:call).with('domain.create', 'test.com', hash_including(
        nameservers: ['ns1.test.net', 'ns2.test.net'],
        duration: 1
      ))

      domain.create('test.com')
    ensure
      ENV.delete('GANDI_CONTACT_OWNER')
    end
  end

  describe '#contact' do
    it "returns ENV GANDI_CONTACT_OWNER in non-development" do
      ENV['GANDI_CONTACT_OWNER'] = 'OWNER-HANDLE'
      expect(domain.contact).to eq('OWNER-HANDLE')
    ensure
      ENV.delete('GANDI_CONTACT_OWNER')
    end
  end
end
