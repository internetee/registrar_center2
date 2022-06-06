# frozen_string_literal: true

class ApiConnector
  class LastNotificationChecker < ApiConnector

    ACTION = 'check_notification'
    ENDPOINT = {
      method: 'get',
      endpoint: '/registrar/notifications',
    }.freeze

    def check_notification
      request(url: endpoint_url, method: method)
    end
  end
end
