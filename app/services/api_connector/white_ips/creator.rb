# frozen_string_literal: true

class ApiConnector
  module WhiteIps
    class Creator < ApiConnector
      ACTION = 'create_white_ip'
      ENDPOINT = {
        method: 'post',
        endpoint: '/white_ips',
      }.freeze

      def create_white_ip(payload: nil)
        request(url: endpoint_url,
                method: method, params: white_ip_params(payload))
      end

      private

      def white_ip_params(payload)
        {
          white_ip: payload.except(:id).as_json,
        }
      end
    end
  end
end
