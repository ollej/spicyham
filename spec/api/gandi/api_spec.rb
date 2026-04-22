require 'rails_helper'

RSpec.describe Gandi::API do
  describe '.parse_error' do
    it "extracts text within brackets from error message" do
      result = described_class.parse_error("Some error [Domain not found]")
      expect(result).to eq("Domain not found")
    end

    it "handles error with only bracketed text" do
      result = described_class.parse_error("[Access denied]")
      expect(result).to eq("Access denied")
    end
  end
end
