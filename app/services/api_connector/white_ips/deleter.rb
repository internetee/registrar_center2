# frozen_string_literal: true

class ApiConnector
  module WhiteIps
    class Deleter < ApiConnector
      ACTION = 'delete_white_ip'
      ENDPOINT = {
        method: 'delete',
        endpoint: '/white_ips',
      }.freeze

      def delete_white_ip(id: '')
        request(url: url_with_id(id), method: method)
      end
    end
  end
end
