# frozen_string_literal: true

class ApiConnector
  module Domains
    class All < ApiConnector
      ENDPOINT = {
        method: 'get',
        endpoint: '/domains',
      }.freeze
      ACTION = 'load_all_domains'

      def load_all_domains(params = {})
        request(url: endpoint_url, params: params, method: method)
      end
    end
  end
end
