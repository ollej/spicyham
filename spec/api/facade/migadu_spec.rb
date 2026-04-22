require 'rails_helper'

RSpec.describe Facade::Migadu do
  let(:facade) { described_class.new(key: 'test-key', domain: 'example.com', user: 'testuser') }

  describe '#list' do
    it "returns sorted Forwarding array from address_aliases" do
      allow(facade).to receive(:request_and_parse).and_return({
        "address_aliases" => [
          { "local_part" => "zebra", "destinations" => ["z@example.com"] },
          { "local_part" => "alpha", "destinations" => ["a@example.com"] }
        ]
      })

      result = facade.list
      expect(result).to all(be_a(Facade::Forwarding))
      expect(result.map(&:source)).to eq(['alpha', 'zebra'])
    end

    it "raises Facade::Error on Migadu::Error" do
      allow(facade).to receive(:request_and_parse).and_raise(::Migadu::Error, "API error")
      expect { facade.list }.to raise_error(Facade::Error, "API error")
    end
  end

  describe '#create' do
    it "calls request_and_parse with local_part and destinations" do
      expect(facade).to receive(:request_and_parse).with(:post, "domains/example.com/aliases", {
        local_part: 'alias',
        destinations: ['fwd@example.com']
      })

      facade.create(email: 'alias', destinations: ['fwd@example.com'])
    end
  end

  describe '#delete' do
    it "calls request_and_parse with correct path" do
      expect(facade).to receive(:request_and_parse).with(:delete, "domains/example.com/aliases/alias")
      facade.delete(email: 'alias')
    end
  end
end
