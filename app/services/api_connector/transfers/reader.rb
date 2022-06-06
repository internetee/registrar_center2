# frozen_string_literal: true

class ApiConnector
  module Transfers
    class Reader < ApiConnector
      ACTION = 'read_transfers'
      ENDPOINT = {
        method: 'get',
        endpoint: '/domains',
      }.freeze

      def read_transfers(domain_name: '')
        request(url: url_with_id(domain_name), method: method)
      end

      private

      def url_with_id(domain_name)
        "#{endpoint_url}/#{domain_name}/transfer_info"
      end
    end
  end
end
