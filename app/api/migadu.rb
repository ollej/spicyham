require "net/http"
require "json"

module Migadu
  extend self

  BASE_URL = "https://api.migadu.com/v1"

  def request_and_parse(method, path, data = nil)
    parse_response(request(method, path, data))
  end

  private

  def request(method, path, data = nil)
    url = URI.parse("#{BASE_URL}/#{path}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    req = case method
    when :get    then Net::HTTP::Get.new(url.path)
    when :post   then Net::HTTP::Post.new(url.path)
    when :delete then Net::HTTP::Delete.new(url.path)
    else raise ArgumentError, "Unsupported HTTP method: #{method}"
    end

    req.basic_auth(@api_user, @api_key)
    req["Content-Type"] = "application/json"

    if data && method == :post
      req.body = data.to_json
    end

    http.request(req)
  end

  def parse_response(response)
    case response.code.to_i
    when 200..299
      JSON.parse(response.body) if response.body && !response.body.empty?
    else
      message = begin
        JSON.parse(response.body)["message"]
      rescue
        response.message
      end
      raise Migadu::Error.new(message)
    end
  end

  class Error < StandardError; end
end
