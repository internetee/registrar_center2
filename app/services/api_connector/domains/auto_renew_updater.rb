# frozen_string_literal: true

class ApiConnector
  module Domains
    class AutoRenewUpdater < ApiConnector
      ACTION = 'update_auto_renew'
      ENDPOINT = {
        method: 'put',
        endpoint: '/domains',
      }.freeze

      def update_auto_renew(payload:)
        request(url: "#{url_with_id(CGI.escape(payload[:name]))}/auto_renew",
                method: method,
                params: { auto_renew: payload.slice(:enabled, :cycle_id) })
      end
    end
  end
end
