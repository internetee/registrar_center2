require 'rails_helper'

RSpec.describe AccountController, type: :controller do
  options = [
    {
      method: :index,
      http_method: :get,
      format: :csv,
    },
    {
      method: :show,
      http_method: :get,
    },
    {
      method: :update,
      http_method: :put,
      params: {
        account: {
          billing_email: Faker::Internet.email,
          iban: Faker::Bank.iban,
          accept_pdf_invoices: '1',
        },
      },
    },
    {
      method: :update_balance_auto_reload,
      http_method: :post,
      params: {
        account: {
          auto_reload_amount: 100,
          auto_reload_threshold: 10,
        },
      },
    },
    {
      method: :disable_balance_auto_reload,
      http_method: :get,
    },
    {
      method: :switch_user,
      http_method: :post,
      params: {
        account: {
          user_id: 8,
        },
      },
    },
  ]

  it_behaves_like 'Base controller with auth', options
end