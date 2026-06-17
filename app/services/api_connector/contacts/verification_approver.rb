# frozen_string_literal: true

class ApiConnector
  module Contacts
    class VerificationApprover < ApiConnector
      ACTION = 'approve_contact_verification'
      ENDPOINT = {
        method: 'post',
        endpoint: '/contacts/approve_verification',
      }.freeze

      def approve_contact_verification(params = {})
        request(url: url_with_id(params[:id]),
                method: method)
      end
    end
  end
end
