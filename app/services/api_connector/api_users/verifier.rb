# frozen_string_literal: true

class ApiConnector
  module ApiUsers
    class Verifier < ApiConnector
      ACTION = 'verify_api_user'
      ENDPOINT = {
        method: 'post',
        endpoint: '/api_users/verify',
      }.freeze

      def verify_api_user(params = {})
        request(url: url_with_id(params[:id]),
                method: method)
      end
    end
  end
end
