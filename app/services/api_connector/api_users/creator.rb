# frozen_string_literal: true

class ApiConnector
  module ApiUsers
    class Creator < ApiConnector
      ACTION = 'create_api_user'
      ENDPOINT = {
        method: 'post',
        endpoint: '/api_users',
      }.freeze

      def create_api_user(payload: nil)
        request(url: endpoint_url,
                method: method, params: api_user_params(payload))
      end

      private

      def api_user_params(payload)
        {
          api_user: payload.as_json,
        }
      end
    end
  end
end
