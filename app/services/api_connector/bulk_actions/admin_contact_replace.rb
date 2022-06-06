# frozen_string_literal: true

class ApiConnector
  module BulkActions
    class AdminContactReplace < ApiConnector
      ACTION = 'replace_contacts'
      ENDPOINT = {
        method: 'patch',
        endpoint: '/domains/admin_contacts',
      }.freeze

      def replace_contacts(payload: nil)
        request(url: endpoint_url, method: method, params: payload.as_json)
      end
    end
  end
end
