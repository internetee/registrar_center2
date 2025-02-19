class ApiConnector
  module Certificates
    module P12
      class Creator < ApiConnector
        ACTION = 'create_p12'
        ENDPOINT = {
          method: 'post',
          endpoint: '/certificates/p12',
        }.freeze

        def create_p12(payload: nil)
          request(url: endpoint_url, method: method, params: p12_params(payload))
        end

        private

        def p12_params(payload)
          {
            api_user_id: payload[:api_user_id]
          }
        end
      end
    end
  end
end
