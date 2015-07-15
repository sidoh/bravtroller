require 'singleton'
require 'easy_upnp/ssdp_searcher'

require_relative 'authenticator'
require_relative 'client'

module Bravtroller
  class Remote
    IRCC_URN = 'urn:schemas-sony-com:service:IRCC:1'

    LIST_METHODS_PARAMS = {
        method: 'getRemoteControllerInfo',
        params: [],
        id: 10,
        version: '1.0'
    }

    class IrccClientFactory
      def initialize(client)
        @client = client
      end

      def create
        if @ircc_client.nil?
          searcher = EasyUpnp::SsdpSearcher.new
          results = searcher.search(IRCC_URN)
          authenticator = Bravtroller::Authenticator.new(@client)

          if !authenticator.authorized?
            raise RuntimeError.new 'Not authorized yet. Please authorize Bravtroller using Bravtroller::Authenticator.'
          end

          if results.empty?
            raise RuntimeError.new "Couldn't find any UPnP devices on the network that looks like a supported Sony device"
          elsif results.count != 1
            raise RuntimeError.new "Found more than one supported Sony device. Please construct Remote manually. Found devices: #{results.inspect}"
          else
            device = results.first
            @ircc_client = device.service(IRCC_URN, cookies: HTTPI::Cookie.new(authenticator.authorize {}))
          end
        end

        @ircc_client
      end
    end

    def initialize(bravia_client, ircc_client_factory = IrccClientFactory.new(bravia_client))
      @bravia_client = bravia_client
      @ircc_client_factory  = ircc_client_factory
    end

    def power_on
      addr = ['<broadcast>', 9]
      sock = UDPSocket.new
      sock.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
      packet_data = (([255] * 6) + (@bravia_client.hw_addr.split(':').map(&:hex) * 16)).pack('C*')
      sock.send(packet_data, 0, addr[0], addr[1])

      true
    end

    def press_button(button_key)
      raise RuntimeError.new "Undefined button: #{button_key}" if ircc_codes[button_key].nil?

      @ircc_client_factory.create.X_SendIRCC IRCCCode: ircc_codes[button_key]
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