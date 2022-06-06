# frozen_string_literal: true

class ApiConnector
  module Contacts
    class Deleter < ApiConnector
      ACTION = 'delete_contact'
      ENDPOINT = {
        method: 'delete',
        endpoint: '/contacts',
      }.freeze

      def delete_contact(payload: nil)
        request(url: url_with_id(payload[:id]), method: method,
                params: contact_params(payload))
      end

      private

      def contact_params(payload)
        {
          legal_document: payload[:legal_document],
        }
      end
    end
  end
end
