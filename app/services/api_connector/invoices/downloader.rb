# frozen_string_literal: true

class ApiConnector
  module Invoices
    class Downloader < ApiConnector
      ACTION = 'download_invoice'
      ENDPOINT = {
        method: 'get',
        endpoint: '/invoices',
      }.freeze

      def download_invoice(id: '')
        request(url: url_with_id(id), method: method)
      end

      private

      def url_with_id(id)
        "#{endpoint_url}/#{id}/download"
      end
    end
  end
end
