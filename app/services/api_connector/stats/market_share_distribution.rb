# frozen_string_literal: true

class ApiConnector
  module Stats
    class MarketShareDistribution < ApiConnector
      ENDPOINT = {
        method: 'get',
        endpoint: '/stats/market_share_distribution',
      }.freeze
      ACTION = 'get_market_share_data'

      def get_market_share_data(params = {})
        request(url: endpoint_url, params: params, method: method)
      end
    end
  end
end
