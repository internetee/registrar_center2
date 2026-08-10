# frozen_string_literal: true

class ApiConnector
  module Domains
    class PendingUpdateCanceller < ApiConnector
      ACTION = 'cancel_pending_update'
      ENDPOINT = {
        method: 'delete',
        endpoint: '/domains',
      }.freeze

      def cancel_pending_update(payload: nil)
        request(url: url_with_id(CGI.escape(payload[:name])), method: method)
      end

      private

      def url_with_id(domain_name)
        "#{endpoint_url}/#{domain_name}/pending_update"
      end
    end
  end
end
