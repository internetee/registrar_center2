require 'rails_helper'

RSpec.describe Stats::MarketShareController, type: :controller do
  options = [
    {
      method: :domains_by_registrar,
      http_method: :get,
      params: {
        search: {
          start_date: '01.22',
        },
      },
    },
  ]

  it_behaves_like 'Base controller with auth', options
end