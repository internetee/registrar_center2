# frozen_string_literal: true

class ApiConnector
  module Auth
    class OmniauthTaraChecker < ApiConnector
      ACTION = 'check_omniauth_user_info'
      ENDPOINT = {
        method: 'post',
        endpoint: '/registrar/auth/tara_callback',
      }.freeze

      def check_omniauth_user_info(payload: nil)
        request(url: endpoint_url,
                method: method, params: payload)
      end
    end
  end
end
