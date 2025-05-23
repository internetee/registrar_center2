require 'rails_helper'

RSpec.describe DomainsController, type: :controller do
  legal_file = File.join(Rails.root, '/spec/fixtures/files/legal_doc.pdf')
  transfer_file = File.join(Rails.root, '/spec/fixtures/files/bulk_domain_transfer.csv')
  uploaded_file = Rack::Test::UploadedFile.new(File.open(legal_file))
  transfer_file_encoded = Base64.encode64(File.read(transfer_file))
  domain = 'example092022.ee'

  options = [
    {
      method: :index,
      http_method: :get,
      format: :csv,
      params: {
        search: {
          s: 'name asc',
        },
      },
    },
    {
      method: :create,
      http_method: :post,
      params: {
        domain: {
          name: domain,
          reserved_pw: Faker::Internet.password,
          registrant: {
            code: '1111111:65B7EB55',
          },
          period: '6m',
          contacts_attributes: {
            '1': {
              code: '1111111:65B7EB55',
              type: 'admin',
            },
            '2': {
              code: '1111111:65B7EB55',
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
      method: :show,
      http_method: :get,
      params: {
        domain_name: domain,
      },
    },
    {
      method: :edit,
      http_method: :get,
      params: {
        domain_name: domain,
      },
    },
    {
      method: :update,
      http_method: :put,
      params: {
        domain: {
          name: domain,
          registrant: {
            code: '1111111:65B7EB55',
          },
        },
      },
    },
    {
      method: :renew,
      http_method: :post,
      params: {
        domain: {
          name: domain,
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
          batch_file: transfer_file_encoded,
          # name: 'example.ee',
          # transfer_code: Faker::Internet.device_token,
        },
      },
    },
    {
      method: :destroy,
      http_method: :delete,
      params: {
        domain: {
          name: domain,
          registrant: {
            verified: true,
          },
          legal_document: uploaded_file,
        },
      },
    },
    {
      method: :regenerate_transfer_code,
      http_method: :put,
      params: {
          domain_name: domain,
      },
    }
  ]

  it_behaves_like 'Base controller with auth', options
end
