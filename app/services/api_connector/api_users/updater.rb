# frozen_string_literal: true

class ApiConnector
  module ApiUsers
    class Updater < ApiConnector
      ACTION = 'update_api_user'
      ENDPOINT = {
        method: 'put',
        endpoint: '/api_users',
      }.freeze

      def update_api_user(payload: nil)
        request(url: url_with_id(payload[:id]),
                method: method, params: api_user_params(payload))
      end

      private

      def api_user_params(payload)
        {
          api_user: payload.except(:id).as_json,
        }
      end
    end
  end
end
