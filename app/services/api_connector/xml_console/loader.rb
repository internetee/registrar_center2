# frozen_string_literal: true

class ApiConnector
  module XmlConsole
    class Loader < ApiConnector
      ENDPOINT = {
        method: 'get',
        endpoint: '/registrar/xml_console/load_xml',
      }.freeze
      ACTION = 'load'

      def load(params = {})
        request(url: endpoint_url, params: params, method: method)
      end
    end
  end
end
