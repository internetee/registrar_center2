# frozen_string_literal: true

class ApiConnector
  module Contacts
    class AvailChecker < ApiConnector
      ACTION = 'check_contact'
      ENDPOINT = {
        method: 'put',
        endpoint: '/contacts',
      }.freeze

      def check_contact(id: 0)
        request(url: url_with_id(id), method: method)
      end
    end
  end
end
