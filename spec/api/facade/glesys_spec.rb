require 'rails_helper'

RSpec.describe Facade::Glesys do
  let(:facade) { described_class.new(key: 'test-key', domain: 'example.com', user: 'testuser') }

  describe '#list' do
    it "returns Forwarding array, stripping domain from emailalias" do
      allow(facade).to receive(:request_and_parse).and_return({
        "emailaliases" => [
          { "emailalias" => "test@example.com", "goto" => "fwd@example.com" }
        ]
      })

      result = facade.list
      expect(result).to all(be_a(Facade::Forwarding))
      expect(result.first.source).to eq('test')
      expect(result.first.destinations).to eq(['fwd@example.com'])
    end

    it "raises Facade::Error on Glesys::Error" do
      allow(facade).to receive(:request_and_parse).and_raise(::Glesys::Error, "API error")
      expect { facade.list }.to raise_error(Facade::Error, "API error")
    end
  end

  describe '#create' do
    it "calls request_and_parse with joined destinations" do
      expect(facade).to receive(:request_and_parse).with("createalias", {
        "emailalias" => "alias@example.com",
        "goto" => "a@b.com,c@d.com"
      })

      facade.create(email: 'alias', destinations: ['a@b.com', 'c@d.com'])
    end
  end

  describe '#delete' do
    it "calls request_and_parse with full email" do
      expect(facade).to receive(:request_and_parse).with("delete", {
        "email" => "alias@example.com"
      })

      facade.delete(email: 'alias')
    end
  end
end
