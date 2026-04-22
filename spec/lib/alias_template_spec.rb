require 'rails_helper'

RSpec.describe AliasTemplate do
  describe '#generate' do
    it "replaces {DOMAIN} with parsed domain from URL" do
      result = described_class.new('https://www.example.com/page', '{DOMAIN}').generate
      expect(result).to eq('example')
    end

    it "replaces {RANDOM} with digits" do
      allow(SecureRandom).to receive(:rand).and_return(5)
      result = described_class.new(nil, '{RANDOM}').generate
      expect(result).to match(/\A\d{8}\z/)
    end

    it "replaces {UUID} with a UUID" do
      allow(SecureRandom).to receive(:uuid).and_return('abc-123')
      result = described_class.new(nil, '{UUID}').generate
      expect(result).to eq('abc-123')
    end

    it "replaces {ALPHA} with alphanumeric characters" do
      allow(SecureRandom).to receive(:alphanumeric).with(8).and_return('abcd1234')
      result = described_class.new(nil, '{ALPHA}').generate
      expect(result).to eq('abcd1234')
    end

    it "replaces {HEX} with hex string" do
      allow(SecureRandom).to receive(:hex).with(4).and_return('deadbeef')
      result = described_class.new(nil, '{HEX}').generate
      expect(result).to eq('deadbeef')
    end

    it "handles multiple substitutions in one template" do
      allow(SecureRandom).to receive(:uuid).and_return('uuid-val')
      result = described_class.new('https://shop.example.com', '{DOMAIN}-{UUID}').generate
      expect(result).to eq('example-uuid-val')
    end

    it "defaults to {DOMAIN} template when template is blank" do
      result = described_class.new('https://example.com', '').generate
      expect(result).to eq('example')
    end

    it "returns empty for {DOMAIN} when URL is nil" do
      result = described_class.new(nil, '{DOMAIN}').generate
      expect(result).to eq('')
    end
  end

  describe 'URL parsing' do
    it "strips protocol, www, path, query, fragment, and port" do
      result = described_class.new('https://www.example.com:8080/path?q=1#frag', '{DOMAIN}').generate
      expect(result).to eq('example')
    end

    it "handles .co.uk second-level TLD" do
      result = described_class.new('https://shop.co.uk', '{DOMAIN}').generate
      expect(result).to eq('shop')
    end

    it "handles .com.au second-level TLD" do
      result = described_class.new('https://shop.com.au', '{DOMAIN}').generate
      expect(result).to eq('shop')
    end

    it "handles .co.jp second-level TLD" do
      result = described_class.new('https://shop.co.jp', '{DOMAIN}').generate
      expect(result).to eq('shop')
    end

    it "handles .com.br second-level TLD" do
      result = described_class.new('https://shop.com.br', '{DOMAIN}').generate
      expect(result).to eq('shop')
    end

    it "handles .co.za second-level TLD" do
      result = described_class.new('https://shop.co.za', '{DOMAIN}').generate
      expect(result).to eq('shop')
    end

    it "handles .com.sg second-level TLD" do
      result = described_class.new('https://shop.com.sg', '{DOMAIN}').generate
      expect(result).to eq('shop')
    end

    it "handles subdomains correctly" do
      result = described_class.new('https://sub.example.com', '{DOMAIN}').generate
      expect(result).to eq('example')
    end

    it "extracts domain from email-like input" do
      result = described_class.new('user@example.com', '{DOMAIN}').generate
      expect(result).to eq('example')
    end
  end
end
