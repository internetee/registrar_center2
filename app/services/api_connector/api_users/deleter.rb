# frozen_string_literal: true

class ApiConnector
  module ApiUsers
    class Deleter < ApiConnector
      ACTION = 'delete_api_user'
      ENDPOINT = {
        method: 'delete',
        endpoint: '/api_users',
      }.freeze

      def delete_api_user(id: '')
        request(url: url_with_id(id), method: method)
      end
    end
  end
end
