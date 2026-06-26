# frozen_string_literal: true

class ApiConnector
  module Contacts
    class VerificationRejecter < ApiConnector
      ACTION = 'reject_contact_verification'
      ENDPOINT = {
        method: 'post',
        endpoint: '/contacts/reject_verification',
      }.freeze

      def reject_contact_verification(params = {})
        request(url: url_with_id(params[:id]),
                method: method)
      end
    end
  end
end
