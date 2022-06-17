require 'rails_helper'

RSpec.describe DomainsController, type: :controller do
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
        domain_name: 'example.ee',
      },
    },
    {
      method: :destroy,
      http_method: :delete,
      params: {
        domain: {
          name: 'example.ee',
          registrant: {
            verified: true,
          },
        },
      },
    },
    {
      method: :edit,
      http_method: :get,
      params: {
        domain_name: 'example.ee',
      },
    },
    {
      method: :update,
      http_method: :put,
      params: {
        domain: {
          name: 'example.ee',
          registrant: {
            code: Faker::Lorem.word,
          },
        },
      },
    },
    {
      method: :create,
      http_method: :post,
      params: {
        domain: {
          name: 'example.ee',
          reserved_pw: Faker::Internet.password,
          registrant: {
            code: Faker::Lorem.word,
          },
          period: '6m',
          contacts_attributes: {
            '1': {
              code: Faker::Lorem.word,
              type: 'admin',
            },
            '2': {
              code: Faker::Lorem.word,
              type: 'tech',
            },
          },
          nameservers_attributes: {
            '1': {
              hostname: "ns1.#{Faker::Internet.domain_name}",
              ipv4: Faker::Internet.ip_v4_address,
              ipv6: Faker::Internet.ip_v6_address,
            },
            '2': {
              hostname: "ns2.#{Faker::Internet.domain_name}",
              ipv4: Faker::Internet.ip_v4_address,
              ipv6: Faker::Internet.ip_v6_address,
            },
          },
          dnskeys_attributes: {
            '1': {
              flags: [256, 257].sample,
              protocol: 3,
              alg: [3, 5, 6, 7, 8, 10, 13, 14].sample,
              public_key: Faker::Crypto.sha256,
            },
          }
        },
      },
    },
    {
      method: :renew,
      http_method: :post,
      params: {
        domain: {
          name: 'wwww.ee',
          exp_date: '2022-12-16',
          period: '6m',
        },
      },
    },
    {
      method: :transfer,
      http_method: :post,
      params: {
        domain: {
          batch_file: "RG9tYWluO1RyYW5zZmVyIGNvZGUNCnd3d3cuZWU7YWQ0YmEyNWMzNjZiNDky\nNzgxZGU3NGMzNDg2ZjJlYzMNCnFxcS5lZTs1MzVkNTdhNTI1OGJhNTYxZDQ2\nOTMzOTc0MmQxMGM4OA==\n",
          # name: 'example.ee',
          # transfer_code: Faker::Internet.device_token,
        },
      },
    },
  ]

  it_behaves_like 'Base controller with auth', options
end