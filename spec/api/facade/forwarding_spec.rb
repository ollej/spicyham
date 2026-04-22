require 'rails_helper'

RSpec.describe Facade::Forwarding do
  describe 'attributes' do
    it "stores source, domain, and destinations" do
      fwd = described_class.new(source: 'test', domain: 'example.com', destinations: ['a@b.com'])
      expect(fwd.source).to eq('test')
      expect(fwd.domain).to eq('example.com')
      expect(fwd.destinations).to eq(['a@b.com'])
    end
  end

  describe '#destinations_string' do
    it "returns destinations as a sentence" do
      fwd = described_class.new(source: 'x', domain: 'd', destinations: ['a@b.com', 'c@d.com'])
      expect(fwd.destinations_string).to eq('a@b.com and c@d.com')
    end

    it "returns empty string for empty destinations" do
      fwd = described_class.new(source: 'x', domain: 'd', destinations: [])
      expect(fwd.destinations_string).to eq('')
    end
  end
end
