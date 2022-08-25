# frozen_string_literal: true

class ApiConnector
  module Stats
    class MarketShare < ApiConnector
      ENDPOINT = {
        method: 'get',
        endpoint: '/stats/market_share',
      }.freeze
      ACTION = 'get_market_share_data'

      def get_market_share_data(params = {})
        request(url: endpoint_url, params: params, method: method)
      end
    end
  end
end
