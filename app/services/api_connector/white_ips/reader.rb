# frozen_string_literal: true

class ApiConnector
  module WhiteIps
    class Reader < ApiConnector
      ACTION = 'read_white_ip'
      ENDPOINT = {
        method: 'get',
        endpoint: '/white_ips',
      }.freeze

      def read_white_ip(id: '')
        request(url: url_with_id(id), method: method)
      end
    end
  end
end
