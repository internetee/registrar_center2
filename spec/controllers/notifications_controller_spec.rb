require 'rails_helper'

RSpec.describe NotificationsController, type: :controller do
  options = [
    {
      method: :mark_as_read,
      http_method: :get,
      params: {
        id: 50,
      },
    },
  ]

  it_behaves_like 'Base controller with auth', options
end