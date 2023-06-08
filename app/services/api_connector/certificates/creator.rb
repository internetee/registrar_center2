# frozen_string_literal: true

class ApiConnector
  module Certificates
    class Creator < ApiConnector
      ACTION = 'create_cert'
      ENDPOINT = {
        method: 'post',
        endpoint: '/certificates',
      }.freeze

      def create_cert(payload: nil)
        request(url: endpoint_url, method: method, params: cert_params(payload))
      end

      private

      def cert_params(payload)
        {
          certificate: payload.compact_blank.as_json,
        }
      end
    end
  end
end