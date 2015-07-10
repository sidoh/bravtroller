require 'easy_upnp/ssdp_searcher'

require_relative 'authenticator'

module Bravtroller
  class Remote
    def initialize(ircc_client)
      @ircc_client = ircc_client
      @bravia_client = bravia_client
    end

    def press_button(button_key)
      raise RuntimeError.new "Undefined buton: #{button_key}" if ircc_codes[button_key].nil?

      @ircc_client.X_SendIRCC IRCCCode: ircc_codes[button_key]
    end

    def buttons
      ircc_codes.keys
    end

    private

    def ircc_codes
      return @ircc_codes unless @ircc_codes.nil?

      response = JSON.parse(@bravia_client.post_request('/sony/system', LIST_METHODS_PARAMS).body)

      action_code_pairs = response['result'][1].map do |action|
        [ action['name'], action['value'] ]
      end

      Hash[ action_code_pairs ]
    end
  end
end