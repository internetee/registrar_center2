# frozen_string_literal: true

class ApiConnector
  class NotificationReader < ApiConnector
    ACTION = 'read_notification'
    ENDPOINT = {
      method: 'get',
      endpoint: '/registrar/notifications',
    }.freeze

    def read_notification(id: 0)
      request(url: url_with_id(id), method: method)
    end
  end
end
