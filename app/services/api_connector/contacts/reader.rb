# frozen_string_literal: true

class ApiConnector
  module Contacts
    class Reader < ApiConnector
      ACTION = 'read_contact'
      ENDPOINT = {
        method: 'get',
        endpoint: '/contacts',
      }.freeze

      def read_contact(params = {})
        request(url: url_with_id(params[:id]), params: params, method: method)
      end
    end
  end
end
