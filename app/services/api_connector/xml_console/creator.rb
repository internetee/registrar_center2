# frozen_string_literal: true

class ApiConnector
  module XmlConsole
    class Creator < ApiConnector
      ENDPOINT = {
        method: 'post',
        endpoint: '/registrar/xml_console',
      }.freeze
      ACTION = 'create'

      def create(payload: nil)
        request(url: endpoint_url, method: method, params: request_params(payload))
      end

      private

      def request_params(payload)
        {
          payload: payload,
        }
      end
    end
  end
end
