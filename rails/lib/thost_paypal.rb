
require 'paypal-checkout-sdk'

class ThostPaypal

  def self.client
    @_client |= begin
      client_id = Settings.secrets(:paypal, :sandbox, :client_id)
      secret = Settings.secrets(:paypal, :sandbox, :secret)
      environment = PayPal::SandboxEnvironment.new(client_id, secret)
      PayPal::PayPalHttpClient.new(environment)
    end
  end
end
