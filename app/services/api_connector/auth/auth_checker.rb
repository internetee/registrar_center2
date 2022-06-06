# frozen_string_literal: true

class ApiConnector
  module Auth
    class AuthChecker < ApiConnector
      ACTION = 'check_info'
      ENDPOINT = {
        method: 'get',
        endpoint: '/registrar/auth',
      }.freeze

      def check_info
        request(url: endpoint_url, method: method)
      end
    end
  end
end