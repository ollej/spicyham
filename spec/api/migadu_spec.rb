require 'rails_helper'

class MigaduTestClient
  include Migadu

  def initialize(api_user:, api_key:)
    @api_user = api_user
    @api_key = api_key
  end

  public :parse_response, :request
end

RSpec.describe Migadu do
  let(:client) { MigaduTestClient.new(api_user: 'testuser', api_key: 'testkey') }

  describe '#parse_response' do
    it "returns parsed JSON for 200 response" do
      response = double("response", code: "200", body: '{"aliases": []}')
      expect(client.parse_response(response)).to eq({ "aliases" => [] })
    end

    it "returns parsed JSON for any 2xx response" do
      response = double("response", code: "201", body: '{"created": true}')
      expect(client.parse_response(response)).to eq({ "created" => true })
    end

    it "returns nil for 2xx response with empty body" do
      response = double("response", code: "204", body: "")
      expect(client.parse_response(response)).to be_nil
    end

    it "raises Migadu::Error with message from JSON for error response" do
      response = double("response", code: "401", body: '{"message": "Invalid credentials"}')
      expect { client.parse_response(response) }.to raise_error(Migadu::Error, "Invalid credentials")
    end

    it "raises Migadu::Error with response message when body is not JSON" do
      response = double("response", code: "500", body: "Internal Server Error", message: "Internal Server Error")
      expect { client.parse_response(response) }.to raise_error(Migadu::Error, "Internal Server Error")
    end
  end

  describe '#request' do
    let(:mock_http) { instance_double(Net::HTTP) }
    let(:mock_response) { double("response", code: "200", body: '{}') }

    before do
      allow(Net::HTTP).to receive(:new).and_return(mock_http)
      allow(mock_http).to receive(:use_ssl=)
      allow(mock_http).to receive(:request).and_return(mock_response)
    end

    it "builds GET request for :get method" do
      client.request(:get, "domains/example.com/aliases")
    end

    it "raises ArgumentError for unsupported method" do
      expect { client.request(:patch, "path") }.to raise_error(ArgumentError, /Unsupported HTTP method/)
    end
  end
end
