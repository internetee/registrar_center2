# frozen_string_literal: true

class ApiConnector
  module WhiteIps
    class All < ApiConnector
      ENDPOINT = {
        method: 'get',
        endpoint: '/white_ips',
      }.freeze
      ACTION = 'load_all_white_ips'

      def load_all_white_ips(params = {})
        request(url: endpoint_url, params: params, method: method)
      end
    end
  end
end
