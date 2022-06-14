# frozen_string_literal: true

class ApiConnector
  module Account
    class BalanceAutoReloadUpdater < ApiConnector
      ACTION = 'update_auto_reload'
      ENDPOINT = {
        method: 'post',
        endpoint: '/accounts/update_auto_reload_balance',
      }.freeze

      def update_auto_reload(payload: nil)
        request(url: endpoint_url,
                method: method, params: auto_reload_params(payload))
      end

      private

      def auto_reload_params(payload)
        {
          type: payload.as_json,
        }
      end
    end
  end
end