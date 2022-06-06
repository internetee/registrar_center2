# frozen_string_literal: true

class ApiConnector
  module Domains
    class Creator < ApiConnector
      ACTION = 'create_domain'
      ENDPOINT = {
        method: 'post',
        endpoint: '/domains',
      }.freeze

      def create_domain(payload: nil)
        request(url: endpoint_url, method: method, params: domain_params(payload))
      end

      private

      def domain_params(payload)
        {
          domain: {
            name: payload[:name],
            reserved_pw: payload[:reserved_pw],
            registrant: payload[:registrant][:code],
            period_unit: payload[:period][-1].to_s,
            period: payload[:period].to_i,
            nameservers_attributes: payload[:nameservers].map { |n| n.extract!(:hostname, :ipv4, :ipv6) },
            admin_contacts: payload[:contacts].select { |c| c[:type] == 'admin' }.pluck(:code),
            tech_contacts: payload[:contacts].select { |c| c[:type] == 'tech' }.pluck(:code),
            dnskeys_attributes: payload[:dns_keys],
          },
        }
      end
    end
  end
end
