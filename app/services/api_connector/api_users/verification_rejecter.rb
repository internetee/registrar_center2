# frozen_string_literal: true

class ApiConnector
  module ApiUsers
    class VerificationRejecter < ApiConnector
      ACTION = 'reject_api_user_verification'
      ENDPOINT = {
        method: 'post',
        endpoint: '/api_users/reject_verification',
      }.freeze

      def reject_api_user_verification(params = {})
        request(url: url_with_id(params[:id]),
                method: method)
      end
    end
  end
end
