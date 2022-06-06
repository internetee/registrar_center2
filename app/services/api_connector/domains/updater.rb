# frozen_string_literal: true

class ApiConnector
  module Domains
    class Updater < ApiConnector
      ACTION = 'update_domain'
      ENDPOINT = {
        method: 'put',
        endpoint: '/domains',
      }.freeze

      def update_domain(payload: nil)
        request(url: url_with_id(payload[:name]),
                method: method,
                params: domain_params(payload))
      end

      private

      def domain_params(payload)
        {
          domain: payload.compact_blank.as_json,
        }
      end
    end
  end
end
