# frozen_string_literal: true

class ApiConnector
  module Contacts
    class PoiDownloader < ApiConnector
      ACTION = 'download_poi'
      ENDPOINT = {
        method: 'get',
        endpoint: '/contacts/download_poi',
      }.freeze

      def download_poi(params = {})
        request(url: url_with_id(params[:id]),
                method: method)
      end
    end
  end
end
