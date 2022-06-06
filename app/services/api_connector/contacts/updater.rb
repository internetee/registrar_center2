# frozen_string_literal: true

class ApiConnector
  module Contacts
    class Updater < ApiConnector
      ACTION = 'update_contact'
      ENDPOINT = {
        method: 'put',
        endpoint: '/contacts',
      }.freeze

      def update_contact(payload: nil)
        request(url: url_with_id(payload[:id]),
                method: method, params: contact_params(payload))
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
