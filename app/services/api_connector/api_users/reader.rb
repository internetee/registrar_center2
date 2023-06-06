# frozen_string_literal: true

class ApiConnector
  module ApiUsers
    class Reader < ApiConnector
      ACTION = 'read_api_user'
      ENDPOINT = {
        method: 'get',
        endpoint: '/api_users',
      }.freeze

      def read_api_user(id: '')
        request(url: url_with_id(id), method: method)
      end
    end
  end
end
