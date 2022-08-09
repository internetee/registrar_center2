# frozen_string_literal: true

class ApiConnector
  module Domains
    class Renewer < ApiConnector
      ACTION = 'renew_domain'
      ENDPOINT = {
        method: 'post',
        endpoint: '/domains',
      }.freeze

      def renew_domain(payload: nil)
        request(url: url_with_id(CGI.escape(payload[:name])),
                method: method,
                params: renew_params(payload))
      end

      private

      def url_with_id(domain_name)
        "#{endpoint_url}/#{domain_name}/renew"
      end

      def renew_params(payload)
        {
          renews: {
            period_unit: payload[:period][-1].to_s,
            period: payload[:period].to_i,
            exp_date: payload[:exp_date],
          },
        }
      end
    end
  end
end
