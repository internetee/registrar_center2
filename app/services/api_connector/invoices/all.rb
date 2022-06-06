# frozen_string_literal: true

class ApiConnector
  module Invoices
    class All < ApiConnector
      ENDPOINT = {
        method: 'get',
        endpoint: '/invoices',
      }.freeze
      ACTION = 'load_all_invoices'

      def load_all_invoices(params = {})
        request(url: endpoint_url, params: params, method: method)
      end
    end
  end
end
