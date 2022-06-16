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
    {
      method: :create,
      http_method: :post,
      params: {
        contact: {
          name: Faker::Name.name,
          email: 'fake@internet.ee',
          phone: '+372.555555',
          ident: '12345678',
          ident_type: 'org',
          ident_country_code: 'EE',
          country_code: Faker::Address.country_code,
          city: Faker::Address.city,
          street: Faker::Address.street_name,
          zip: Faker::Address.zip_code,
        },
      },
    },
    {
      method: :edit,
      http_method: :get,
      params: {
        contact_code: '1111111:8E3736F2',
      },
    },
    {
      method: :update,
      http_method: :put,
      params: {
        contact: {
          code: '1111111:8E3736F2',
          country_code: Faker::Address.country_code,
          city: Faker::Address.city,
          street: Faker::Address.street_name,
          zip: Faker::Address.zip_code,
          ident: '60001019906',
          ident_type: 'priv',
          ident_country_code: 'EE',
        },
      },
    },
  ]

  it_behaves_like 'Base controller with auth', options
end