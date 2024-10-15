# frozen_string_literal: true

class ApiConnector
  module Contacts
    class Verifier < ApiConnector
      ACTION = 'verify_contact'
      ENDPOINT = {
        method: 'post',
        endpoint: '/contacts/verify',
      }.freeze

      def verify_contact(params = {})
        request(url: url_with_id(params[:id]),
                method: method)
      end
    end
  end
end
