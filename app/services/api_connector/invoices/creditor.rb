# frozen_string_literal: true

class ApiConnector
  module Invoices
    class Creditor < ApiConnector
      ACTION = 'add_credit'
      ENDPOINT = {
        method: 'post',
        endpoint: '/invoices/add_credit',
      }.freeze

      def add_credit(payload: nil)
        request(url: endpoint_url, method: method, params: deposit_params(payload))
      end

      private

      def deposit_params(payload)
        {
          invoice: payload.compact_blank.as_json,
        }
      end
    end
  end
end