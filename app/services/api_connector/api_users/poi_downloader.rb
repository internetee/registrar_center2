# frozen_string_literal: true

class ApiConnector
  module ApiUsers
    class PoiDownloader < ApiConnector
      ACTION = 'download_poi'
      ENDPOINT = {
        method: 'get',
        endpoint: '/api_users/download_poi',
      }.freeze

      def download_poi(params = {})
        request(url: url_with_id(params[:id]),
                method: method)
      end
    end
  end
end
