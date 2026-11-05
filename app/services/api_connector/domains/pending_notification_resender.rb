# frozen_string_literal: true

class ApiConnector
  module Domains
    class PendingNotificationResender < ApiConnector
      ACTION = 'resend_pending_notification'
      ENDPOINT = {
        method: 'post',
        endpoint: '/domains',
      }.freeze

      def resend_pending_notification(payload: nil)
        request(url: url_with_id(CGI.escape(payload[:name])), method: method)
      end

      private

      def url_with_id(domain_name)
        "#{endpoint_url}/#{domain_name}/pending_notification"
      end
    end
  end
end
