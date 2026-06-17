# frozen_string_literal: true

class ApiConnector
  module ApiUsers
    class VerificationApprover < ApiConnector
      ACTION = 'approve_api_user_verification'
      ENDPOINT = {
        method: 'post',
        endpoint: '/api_users/approve_verification',
      }.freeze

      def approve_api_user_verification(params = {})
        request(url: url_with_id(params[:id]),
                method: method,
                params: params[:payload])
      end
    end
  end
end
