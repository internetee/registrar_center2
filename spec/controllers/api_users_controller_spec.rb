require 'rails_helper'

RSpec.describe ApiUsersController, type: :controller do
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
        id: 2,
      },
    },
    {
      method: :create,
      http_method: :post,
      params: {
        api_user: {
          username: Faker::Internet.username,
          password: Faker::Internet.password,
          identity_code: Faker::Number.unique.number(digits: 5),
          roles: 'super',
          active: 'true',
        },
      },
    },
    {
      method: :update,
      http_method: :put,
      params: {
        id: '2',
        api_user: {
          id: '2',
          username: Faker::Internet.username,
          password: Faker::Internet.password,
          identity_code: Faker::Number.unique.number(digits: 5),
          roles: 'super',
          active: 'false',
        },
      },
    },
    {
      method: :destroy,
      http_method: :delete,
      params: {
        id: 18,
      },
    },
  ]

  it_behaves_like 'Base controller with auth', options
end
