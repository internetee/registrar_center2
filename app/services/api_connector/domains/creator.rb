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

      # rubocop:disable Metrics/MethodLength
      def domain_params(payload)
        {
          domain: {
            name: payload[:name],
            reserved_pw: payload[:reserved_pw],
            registrant: payload[:registrant][:code],
            period_unit: payload[:period][-1].to_s,
            period: payload[:period].to_i,
            nameservers_attributes: ns_attrs(payload[:nameservers]),
            admin_contacts: contacts(payload[:contacts], 'admin'),
            tech_contacts: contacts(payload[:contacts], 'tech'),
            dnskeys_attributes: payload[:dns_keys],
          },
        }
      end
      # rubocop:enable Metrics/MethodLength

      def ns_attrs(nameservers)
        nameservers.map { |n| n.extract!(:hostname, :ipv4, :ipv6) }
      end

      def contacts(contacts, type)
        return [] unless contacts

        contacts.select { |c| c[:type] == type }.pluck(:code)
      end
    end
  end
end
