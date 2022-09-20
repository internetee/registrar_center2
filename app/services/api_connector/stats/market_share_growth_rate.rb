# frozen_string_literal: true

class ApiConnector
  module Stats
    class MarketShareGrowthRate < ApiConnector
      ENDPOINT = {
        method: 'get',
        endpoint: '/stats/market_share_growth_rate',
      }.freeze
      ACTION = 'get_market_share_data'

      def get_market_share_data(params = {})
        request(url: endpoint_url, params: params, method: method)
      end
    end
  end
end
