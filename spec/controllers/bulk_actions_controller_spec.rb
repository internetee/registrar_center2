require 'rails_helper'

RSpec.describe BulkActionsController, type: :controller do
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
          old_hostname: "ns1.#{Faker::Internet.domain_name}",
          ipv4: Faker::Internet.ip_v4_address,
          ipv6: Faker::Internet.ip_v6_address,
          batch_file: "ZG9tYWluX25hbWU7VHJhbnNmZXIgY29kZQ0KZXhhbXBsZS5lZTs1ZmIzNTRh\nNWNlOGQ2NTY5YzU5NDI3NzQwYTQzMDE0NA0KZXhhbXBsZTEuZWU7\n",
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