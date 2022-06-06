# frozen_string_literal: true

class ApiConnector
  module Contacts
    class Finder < ApiConnector
      ACTION = 'find'
      ENDPOINT = {
        method: 'get',
        endpoint: '/contacts/search',
      }.freeze

      def find(params = {})
        params = {
          query: params[:q],
          id: params[:id],
        }
        request(url: endpoint_url, params: params, method: method)
      end
    end
  end
end
