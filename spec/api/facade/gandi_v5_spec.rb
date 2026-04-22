require 'rails_helper'

RSpec.describe Facade::GandiV5 do
  let(:facade) { described_class.new(key: 'test-key', domain: 'example.com') }
  let(:forward) { double("Forward", source: 'test', fqdn: 'example.com', destinations: ['fwd@example.com']) }

  describe '#list' do
    it "returns array of Facade::Forwarding from API results" do
      allow(GandiV5::Email::Forward).to receive(:list).and_return([forward])

      result = facade.list
      expect(result).to all(be_a(Facade::Forwarding))
      expect(result.first.source).to eq('test')
    end

    it "passes page: 1 when all is false" do
      expect(GandiV5::Email::Forward).to receive(:list)
        .with('example.com', hash_including(page: 1))
        .and_return([])

      facade.list(all: false)
    end

    it "omits page param when all is true" do
      expect(GandiV5::Email::Forward).to receive(:list)
        .with('example.com', hash_not_including(:page))
        .and_return([])

      facade.list(all: true)
    end

    it "raises Facade::Error on REST errors" do
      allow(GandiV5::Email::Forward).to receive(:list)
        .and_raise(RestClient::Unauthorized.new)

      expect { facade.list }.to raise_error(Facade::Error)
    end
  end

  describe '#create' do
    it "calls Forward.create with correct args" do
      expect(GandiV5::Email::Forward).to receive(:create)
        .with('example.com', 'alias', 'fwd@example.com')

      facade.create(email: 'alias', destinations: ['fwd@example.com'])
    end
  end

  describe '#delete' do
    it "calls delete on Forward instance" do
      mock_forward = double("Forward")
      allow(GandiV5::Email::Forward).to receive(:new)
        .with(fqdn: 'example.com', source: 'alias')
        .and_return(mock_forward)
      expect(mock_forward).to receive(:delete)

      facade.delete(email: 'alias')
    end
  end
end
