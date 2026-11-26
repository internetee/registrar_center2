# frozen_string_literal: true

class ApiConnector
  module Contacts
    class Copier < ApiConnector
      ACTION = 'copy_contact'
      ENDPOINT = {
        method: 'post',
        endpoint: '/contacts/copy',
      }.freeze

      def copy_contact(params = {})
        request(url: url_with_id(params[:id]),
                method: method)
      end
    end
  end
end
