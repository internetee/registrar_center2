# frozen_string_literal: true

class ApiConnector
  module Account
    class UserSwitcher < ApiConnector
      ACTION = 'switch_user'
      ENDPOINT = {
        method: 'put',
        endpoint: '/accounts/switch_user',
      }.freeze

      def switch_user(payload: nil)
        request(url: endpoint_url,
                method: method, params: auth_params(payload))
      end

      private

      def auth_params(payload)
        {
          account: payload.as_json,
        }
      end
    end
  end
end