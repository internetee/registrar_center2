require 'rails_helper'

RSpec.describe BulkActionsController, type: :controller do
  bulk_change_file = File.join(Rails.root, '/spec/fixtures/files/bulk_domain_transfer.csv')
  bulk_change_file_encoded = Base64.encode64(File.read(bulk_change_file))
  options = [
    {
      method: :contact_replace,
      http_method: :post,
      params: {
        bulk_change: {
          current_contact_id: '1111111:65B7EB55',
          new_contact_id: '1111111:0E828F10',
        },
      },
    },
    {
      method: :admin_contact_replace,
      http_method: :post,
      params: {
        bulk_change: {
          current_contact_id: '1111111:90DAE9D2',
          new_contact_id: '1111111:9A8C930A',
        },
      },
    },
    {
      method: :nameserver_change,
      http_method: :post,
      params: {
        bulk_change: {
          new_hostname: "ns1.#{Faker::Internet.domain_name}",
          old_hostname: '',
          ipv4: Faker::Internet.ip_v4_address,
          ipv6: Faker::Internet.ip_v6_address,
          batch_file: bulk_change_file_encoded,
        },
      },
    },
    {
      method: :domain_renew,
      http_method: :post,
      params: {
        bulk_change: {
          domains: 'wwww.ee,wwwww.ee',
          renew_period: '6m',
        },
      },
    },
  ]

  it_behaves_like 'Base controller with auth', options
end