# frozen_string_literal: true

class ApiConnector
  module Domains
    class CsvNameserverBulk < ApiConnector
      ACTION = 'csv_nameserver_bulk'
      ENDPOINT = {
        method: 'post',
        endpoint: '/domains/nameservers/bulk',
      }.freeze

      def csv_nameserver_bulk(csv_content: nil, csv_filename: nil)
        @csv_content = csv_content
        @csv_filename = csv_filename || 'nameserver_bulk.csv'
        request(url: endpoint_url, method: method, params: nil)
      end

      private

      def send_non_get_request(request, method, params)
        # Override parent method to send raw CSV instead of JSON
        request.send(method) do |req|
          req.headers['Content-Type'] = 'text/csv'
          req.headers['Content-Disposition'] = "attachment; filename=\"#{@csv_filename}\""
          req.body = @csv_content
        end
      end
    end
  end
end
