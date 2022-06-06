# frozen_string_literal: true

class ApiConnector
  module Account
    class Updater < ApiConnector
      ACTION = 'update_account'
      ENDPOINT = {
        method: 'put',
        endpoint: '/account',
      }.freeze

      def update_account(payload: nil)
        request(url: endpoint_url,
                method: method, params: account_params(payload))
      end

      private

      def account_params(payload)
        {
          account: payload.compact_blank.as_json,
        }
      end
    end
  end
end