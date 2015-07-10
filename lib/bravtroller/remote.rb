require 'easy_upnp'

module Bravtroller
  class Remote
    def initialize(ircc_client)
      @ircc_client = ircc_client
    end
  end
end