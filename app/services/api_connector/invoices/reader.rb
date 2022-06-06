# frozen_string_literal: true

class ApiConnector
  module Invoices
    class Reader < ApiConnector
      ACTION = 'read_invoice'
      ENDPOINT = {
        method: 'get',
        endpoint: '/invoices',
      }.freeze

      def read_invoice(id: '')
        request(url: url_with_id(id), method: method)
      end
    end
  end
end
