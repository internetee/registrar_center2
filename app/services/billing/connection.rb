module Billing
  module Connection
    BASE_URL = Rails.configuration.customization[:eis_billing_system_base_url]
    INITIATOR = 'registry'.freeze

    def connection
      Faraday.new(options) do |faraday|
        faraday.adapter Faraday.default_adapter
      end
    end

    private

    def options
      {
        headers: {
          'Authorization' => "Bearer #{generate_token}",
          'Content-Type' => 'application/json',
        },
        url: BASE_URL
      }
    end

    def generate_token
      JWT.encode(payload, billing_secret)
    end

    def payload
      { initiator: INITIATOR }
    end

    def billing_secret
      Rails.configuration.customization[:billing_secret]
    end
  end
end
