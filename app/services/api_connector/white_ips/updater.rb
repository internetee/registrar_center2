# frozen_string_literal: true

class ApiConnector
  module WhiteIps
    class Updater < ApiConnector
      ACTION = 'update_white_ip'
      ENDPOINT = {
        method: 'put',
        endpoint: '/white_ips',
      }.freeze

      def update_white_ip(payload: nil)
        request(url: url_with_id(payload[:id]),
                method: method, params: white_ip_params(payload))
      end

      private

      def white_ip_params(payload)
        {
          white_ip: payload.except(:id).as_json,
          locale: I18n.locale
        }
      end
    end
  end
end
