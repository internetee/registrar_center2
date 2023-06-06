# frozen_string_literal: true

class ApiConnector
  module ApiUsers
    class All < ApiConnector
      ENDPOINT = {
        method: 'get',
        endpoint: '/api_users',
      }.freeze
      ACTION = 'load_all_api_users'

      def load_all_api_users(params = {})
        request(url: endpoint_url, params: params, method: method)
      end
    end
  end
end
