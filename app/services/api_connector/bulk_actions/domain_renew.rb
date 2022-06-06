# frozen_string_literal: true

class ApiConnector
  module BulkActions
    class DomainRenew < ApiConnector
      ACTION = 'renew'
      ENDPOINT = {
        method: 'post',
        endpoint: '/domains/renew/bulk',
      }.freeze

      def renew(payload: nil)
        request(url: endpoint_url, method: method, params: payload)
      end
    end
  end
end
