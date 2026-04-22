require 'rails_helper'

RSpec.describe Facade::Gandi do
  let(:mock_email_server) { double("Gandi::Email") }
  let(:facade) { described_class.new(key: 'test-key', domain: 'example.com') }

  before do
    allow(Gandi::API).to receive(:new).and_return(double("Gandi::API"))
    allow(Gandi::Email).to receive(:new).and_return(mock_email_server)
  end

  describe '#list' do
    it "returns array of Facade::Forwarding objects" do
      allow(mock_email_server).to receive(:list).and_return([
        { 'source' => 'test', 'destinations' => ['fwd@example.com'] }
      ])

      result = facade.list
      expect(result).to all(be_a(Facade::Forwarding))
      expect(result.first.source).to eq('test')
      expect(result.first.destinations).to eq(['fwd@example.com'])
    end

    it "raises Facade::Error on XMLRPC fault" do
      allow(mock_email_server).to receive(:list)
        .and_raise(XMLRPC::FaultException.new(500, "[Access denied]"))

      expect { facade.list }.to raise_error(Facade::Error, 'Access denied')
    end
  end

  describe '#create' do
    it "calls email_server.create with correct args" do
      expect(mock_email_server).to receive(:create)
        .with('alias', { 'destinations' => ['fwd@example.com'] })

      facade.create(email: 'alias', destinations: ['fwd@example.com'])
    end

    it "raises Facade::Error on XMLRPC fault" do
      allow(mock_email_server).to receive(:create)
        .and_raise(XMLRPC::FaultException.new(500, "[Already exists]"))

      expect { facade.create(email: 'x', destinations: ['y']) }
        .to raise_error(Facade::Error, 'Already exists')
    end
  end

  describe '#delete' do
    it "calls email_server.delete" do
      expect(mock_email_server).to receive(:delete).with('alias')
      facade.delete(email: 'alias')
    end
  end
end
