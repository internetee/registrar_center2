# frozen_string_literal: true

class ApiConnector
  module Domains
    class Deleter < ApiConnector
      ACTION = 'delete_domain'
      ENDPOINT = {
        method: 'delete',
        endpoint: '/domains',
      }.freeze

      def delete_domain(payload: nil)
        request(url: url_with_id(CGI.escape(payload[:name])),
                method: method,
                params: domain_params(payload),
                headers: add_headers(payload))
      end

      private

      def domain_params(payload)
        {
          domain: {
            delete: {
              verified: payload[:registrant] ? payload[:registrant][:verified] : false,
            },
            legal_document: payload[:legal_document],
          },
        }
      end

      def add_headers(payload)
        { 'Auth-Code' => payload[:auth_code] } if payload && payload[:auth_code]
      end
    end
  end
end
