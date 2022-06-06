# frozen_string_literal: true

class ApiConnector
  class NotificationReadMarker < ApiConnector
    ACTION = 'mark_notification_read'
    DEFAULT_PARAMS = {
      notification: {
        read: true,
      },
    }.freeze
    ENDPOINT = {
      method: 'put',
      endpoint: '/registrar/notifications',
    }.freeze

    def mark_notification_read(id: 0)
      request(url: url_with_id(id), method: method, params: DEFAULT_PARAMS)
    end
  end
end
