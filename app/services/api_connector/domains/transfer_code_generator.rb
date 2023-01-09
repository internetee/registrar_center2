# frozen_string_literal: true

class ApiConnector
  module Domains
    class TransferCodeGenerator < ApiConnector
      ACTION = 'regenerate_transfer_code'
      ENDPOINT = {
        method: 'put',
        endpoint: '/domains',
      }.freeze

      def regenerate_transfer_code(payload: nil)
        request(url: url_with_id(CGI.escape(payload[:name])),
                method: method,
                params: transfer_code_generator_params(payload))
      end

      private

      def transfer_code_generator_params(payload)
        {
          domain: payload.compact_blank.as_json,
        }
      end
    end
  end
end
