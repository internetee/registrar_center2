# frozen_string_literal: true

class ApiConnector
  module Certificates
    class Reader < ApiConnector
      ACTION = 'read_certificate'
      ENDPOINT = {
        method: 'get',
        endpoint: '/api_users',
      }.freeze

      def read_certificate(api_user_id:, id:)
        request(url: url_with_api_user_id(api_user_id, id), method: method)
      end

      private

      def url_with_api_user_id(api_user_id, id)
        "#{endpoint_url}/#{api_user_id}/certificates/#{id}"
      end
    end
  end
end
