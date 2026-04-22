require 'rails_helper'

# Host class to test the Glesys mixin through
class GlesysTestClient
  include Glesys
  MODULE = 'email'

  def initialize(api_id:, api_key:)
    @api_id = api_id
    @api_key = api_key
  end

  # Expose private methods for testing
  public :parse_response, :request
end

RSpec.describe Glesys do
  let(:client) { GlesysTestClient.new(api_id: 'testid', api_key: 'testkey') }

  describe '#parse_response' do
    it "returns data for status 200, excluding status and debug keys" do
      body = {
        "response" => {
          "status" => { "code" => 200, "text" => "OK" },
          "debug" => {},
          "emailaliases" => [{ "emailalias" => "test@example.com" }]
        }
      }.to_json

      result = client.parse_response(body)
      expect(result).to eq([{ "emailalias" => "test@example.com" }])
    end

    it "raises Glesys::Error for non-200 status" do
      body = {
        "response" => {
          "status" => { "code" => 401, "text" => "Unauthorized" }
        }
      }.to_json

      expect { client.parse_response(body) }.to raise_error(Glesys::Error, "Unauthorized")
    end

    it "raises error for malformed JSON" do
      expect { client.parse_response("not json") }.to raise_error(JSON::ParserError)
    end
  end

  describe '#request' do
    let(:mock_http) { instance_double(Net::HTTP) }
    let(:mock_response) { double("response", body: '{}') }

    before do
      allow(Net::HTTP).to receive(:new).and_return(mock_http)
      allow(mock_http).to receive(:use_ssl=)
      allow(mock_http).to receive(:request).and_return(mock_response)
    end

    it "builds URL from MODULE and action" do
      expect(Net::HTTP).to receive(:new).with("api.glesys.com", 443).and_return(mock_http)
      client.request("list", domainname: "example.com")
    end

    it "uses basic auth with api_id and api_key" do
      client.request("list")
    end
  end
end
