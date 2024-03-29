require 'rails_helper'

RSpec.describe WhiteIpsController, type: :controller do
  options = [
    {
      method: :index,
      http_method: :get,
      format: :csv,
    },
    {
      method: :show,
      http_method: :get,
      params: {
        id: 4,
      },
    },
    {
      method: :create,
      http_method: :post,
      params: {
        white_ip: {
          address: Faker::Internet.ip_v4_address,
          interfaces: ['api'],
        },
      },
    },
    {
      method: :update,
      http_method: :put,
      params: {
        id: '4',
        white_ip: {
          id: '4',
          address: Faker::Internet.ip_v4_address,
        },
      },
    },
    {
      method: :destroy,
      http_method: :delete,
      params: {
        id: 39,
      },
    },
  ]

  it_behaves_like 'Base controller with auth', options
end