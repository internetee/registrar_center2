# frozen_string_literal: true

class ApiConnector
  module Account
    class BalanceAutoReloadDeleter < ApiConnector
      ACTION = 'disable_auto_reload'
      ENDPOINT = {
        method: 'get',
        endpoint: '/accounts/disable_auto_reload_balance',
      }.freeze

      def disable_auto_reload
        request(url: endpoint_url, method: method)
      end
    end
  end
end