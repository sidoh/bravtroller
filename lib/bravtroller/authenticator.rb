require 'net/http'
require 'json'
require 'base64'

module Bravtroller
  class Authenticator
    CLIENT_ID = 'bravtroller:de7cd7d5-a9a0-44a1-aba1-57d973a0ee8a'

    AUTH_REQUEST_PARAMS =
        {
            method: 'actRegister',
            params: [
                {
                    clientid: CLIENT_ID,
                    nickname: 'Bravtroller',
                    level: 'private',
                },
                [
                    value: 'yes',
                    function: 'WOL'
                ]
            ],
            id: 8,
            version: '1.0'
        }

    def initialize(bravia_address)
      @bravia_address = bravia_address
    end

    def authorized?
      response = post_request('/sony/accessControl', AUTH_REQUEST_PARAMS)
      '200' == response.code
    end

    def authorize(&callback)
      response = post_request('/sony/accessControl', AUTH_REQUEST_PARAMS)

      if response.code == '401'
        challenge_value = callback.call(response)
        auth_value = "Basic #{Base64.encode64(":#{challenge_value}")}"
        headers = { 'Authorization' => auth_value }

        auth_response = post_request('/sony/accessControl', AUTH_REQUEST_PARAMS, headers)

        extract_cookie(auth_response)
      else
        # Already authorized, but the Set-Cookie header should still be set
        extract_cookie(response)
      end
    end

    private

    def extract_cookie(response)
      response['Set-Cookie'].split(';').first
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