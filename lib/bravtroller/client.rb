require 'net/http'
require 'json'

module Bravtroller
  class Client
    def initialize(bravia_address)
      @bravia_address = bravia_address
    end

    def hw_addr
      arp = `which arp`.strip

      raise RuntimeError.new "Couldn't find arp binary" if arp.empty?

      result = `#{arp} #{@bravia_address}`
      hw_addr_match = result.match(/((?:[a-f0-9]{1,2}:?){6})/i)
      if hw_addr_match.nil?
        nil
      else
        # On my mac, octets with the most significant nibble = 0 show as "0" instead of "00"
        hw_addr_match
            .captures
            .first
            .split(':')
            .map { |x| "#{x.length == 1 ? '0' : ''}#{x}" }
            .join(':')
      end
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