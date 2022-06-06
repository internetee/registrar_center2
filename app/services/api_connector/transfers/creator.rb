# frozen_string_literal: true

class ApiConnector
  module Transfers
    class Creator < ApiConnector
      ACTION = 'create_transfer'
      ENDPOINT = {
        method: 'post',
        endpoint: '/domains/transfer',
      }.freeze

      def create_transfer(payload: nil)
        request(url: endpoint_url, method: method,
                params: transfer_params(payload))
      end

      private

      def transfer_params(payload)
        {
          data: {
            domain_transfers: domain_transfers(payload),
          },
        }
      end

      def domain_transfers(payload)
        payload[:batch_file] || [{ domain_name: payload[:name],
                                   transfer_code: payload[:transfer_code] }]
      end
    end
  end
end
