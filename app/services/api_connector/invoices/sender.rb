# frozen_string_literal: true

class ApiConnector
  module Invoices
    class Sender < ApiConnector
      ACTION = 'send_invoice'
      ENDPOINT = {
        method: 'post',
        endpoint: '/invoices',
      }.freeze

      def send_invoice(payload: nil)
        request(url: url_with_id(payload[:id]), method: method, params: invoice_params(payload))
      end

      private

      def url_with_id(id)
        "#{endpoint_url}/#{id}/send_to_recipient"
      end

      def invoice_params(payload)
        {
          invoice: payload.as_json,
        }
      end
    end
  end
end