# frozen_string_literal: true

class ApiConnector
  module Account
    class AllActivities < ApiConnector
      ENDPOINT = {
        method: 'get',
        endpoint: '/account',
      }.freeze
      ACTION = 'load_all_activities'

      def load_all_activities(params = {})
        request(url: endpoint_url, params: params, method: method)
      end
    end
  end
end
