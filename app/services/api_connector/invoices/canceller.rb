# frozen_string_literal: true

class ApiConnector
  module Invoices
    class Canceller < ApiConnector
      ACTION = 'cancel_invoice'
      ENDPOINT = {
        method: 'put',
        endpoint: '/invoices',
      }.freeze

      def cancel_invoice(payload: nil)
        request(url: url_with_id(payload[:id]), method: method)
      end

      private

      def url_with_id(id)
        "#{endpoint_url}/#{id}/cancel"
      end
    end
  end
end
