require 'net/http'
require 'json'

module Bravtroller
  class Client
    LIST_METHODS_PARAMS = {
        method: 'getRemoteControllerInfo',
        params: [],
        id: 10,
        version: '1.0'
    }

    def initialize(bravia_address)
      @bravia_address = bravia_address
    end

    def ircc_codes
      response = JSON.parse(post_request('/sony/system', LIST_METHODS_PARAMS).body)

      action_code_pairs = response['result'][1].map do |action|
        [ action['name'], action['value'] ]
      end

      Hash[ action_code_pairs ]
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