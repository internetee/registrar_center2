# frozen_string_literal: true

class ApiConnector
  module Certificates
    class Downloader < ApiConnector
      ACTION = 'download_certificate'
      ENDPOINT = {
        method: 'get',
        endpoint: '/api_users',
      }.freeze

      def download_certificate(params = {})
        request(url: url_with_api_user_id(params), method: method, params: params.slice(:type))
      end

      private

      def url_with_api_user_id(params)
        "#{endpoint_url}/#{params[:api_user_id]}/certificates/#{params[:id]}/download"
      end
    end
  end
end
