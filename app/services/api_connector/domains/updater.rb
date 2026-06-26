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
        request(url: url_with_id(CGI.escape(payload[:name])),
                method: method,
                params: domain_params(payload))
      end

      private

      PRESERVE_EMPTY_ARRAY_KEYS = %i[contacts].freeze

      def domain_params(payload)
        preserved = payload.slice(*PRESERVE_EMPTY_ARRAY_KEYS)
        domain = payload.except(*PRESERVE_EMPTY_ARRAY_KEYS).compact_blank.as_json
        preserved.each { |key, value| domain[key.to_s] = value unless value.nil? }

        { domain: domain }
      end
    end
  end
end
