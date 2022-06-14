# frozen_string_literal: true

class ApiConnector
  module Account
    class Reader < ApiConnector
      ACTION = 'read_account_details'
      ENDPOINT = {
        method: 'get',
        endpoint: '/accounts/details',
      }.freeze

      def read_account_details
        request(url: endpoint_url, method: method)
      end
    end
  end
end