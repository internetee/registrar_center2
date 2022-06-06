# frozen_string_literal: true

class ApiConnector
  module Contacts
    class Creator < ApiConnector
      ACTION = 'create_contact'
      ENDPOINT = {
        method: 'post',
        endpoint: '/contacts',
      }.freeze

      def create_contact(payload: nil)
        request(url: endpoint_url, method: method, params: contact_params(payload))
      end

      private

      def contact_params(payload)
        {
          contact: payload.except(:id).compact_blank.as_json,
        }
      end
    end
  end
end
