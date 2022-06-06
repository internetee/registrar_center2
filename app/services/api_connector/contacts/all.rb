# frozen_string_literal: true

class ApiConnector
  module Contacts
    class All < ApiConnector
      ACTION = 'load_all_contacts'
      ENDPOINT = {
        method: 'get',
        endpoint: '/contacts',
      }.freeze

      def load_all_contacts(params = {})
        request(url: endpoint_url, params: params, method: method)
      end
    end
  end
end
