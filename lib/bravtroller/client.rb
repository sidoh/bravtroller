require 'net/http'
require 'json'

module Bravtroller
  class Client
    def initialize(bravia_address)
      @bravia_address = bravia_address
    end

    def post_request(path, params = {}, headers = {})
      json = JSON.generate(params)
      uri = URI("http://#{@bravia_address}#{path}")

      Net::HTTP.start(uri.host, uri.port) do |http|
        return http.post(path, json, headers)
      end
    end
  end
end