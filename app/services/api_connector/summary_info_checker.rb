# frozen_string_literal: true

class ApiConnector
  class SummaryInfoChecker < ApiConnector
    ACTION = 'check_info'
    ENDPOINT = {
      method: 'get',
      endpoint: '/registrar/summary',
    }.freeze

    def check_info
      request(url: endpoint_url, method: method)
    end
  end
end
