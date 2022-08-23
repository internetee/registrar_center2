require 'rails_helper'

RSpec.describe InvoicesController, type: :controller do
  options = [
    {
      method: :index,
      http_method: :get,
      params: {
        search: {
          invoice_status: 'account_activity_id_not_null',
        },
      },
    },
    {
      method: :show,
      http_method: :get,
      params: {
        id: 41,
      },
      format: :pdf,
    },
    {
      method: :download,
      http_method: :get,
      params: {
        id: 41,
      },
    },
    {
      method: :send_to_recipient,
      http_method: :post,
      params: {
        invoice: {
          recipient: Faker::Internet.email,
          id: 41,
        },
      },
    },
    {
      method: :cancel,
      http_method: :post,
      params: {
        invoice: {
          id: 41,
        },
      },
    },
    {
      method: :add_credit,
      http_method: :post,
      params: {
        invoice: {
          amount: 100,
          description: Faker::Lorem.sentence,
        },
      },
    }
  ]

  it_behaves_like 'Base controller with auth', options

end
