require 'rails_helper'

RSpec.describe ContactsController, type: :controller do
  options = [
    {
      method: :index,
      http_method: :get,
    },
    {
      method: :search,
      http_method: :get,
      params: {
        query: 'Vav',
      },
    },
    {
      method: :show,
      http_method: :get,
      params: {
        contact_code: '1111111:8E3736F2',
      },
    },
    {
      method: :delete,
      http_method: :get,
      params: {
        contact_code: '1111111:8E3736F2',
      },
    },
    {
      method: :destroy,
      http_method: :delete,
      params: {
        contact: {
          code: '1111111:4D555060',
        },
      },
    },
  ]

  it_behaves_like 'Base controller with auth', options
end