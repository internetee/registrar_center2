# frozen_string_literal: true

class ApiConnector
  module BulkActions
    class NameserverChange < ApiConnector
      ACTION = 'replace_nameserver'
      ENDPOINT = {
        method: 'put',
        endpoint: '/registrar/nameservers',
      }.freeze

      def replace_nameserver(payload: nil)
        request(url: endpoint_url, method: method, params: nameserver_params(payload))
      end

      private

      def nameserver_params(payload)
        {
          data: {
            type: 'nameserver', id: payload[:id],
            domains: payload[:domains],
            attributes: {
              hostname: payload[:new_hostname],
              ipv4: payload[:ipv4], ipv6: payload[:ipv6]
            }
          },
        }
      end
    end
  end
end

