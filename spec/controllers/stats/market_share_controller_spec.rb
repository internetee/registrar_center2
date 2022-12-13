require 'rails_helper'

RSpec.describe Stats::MarketShareController, type: :controller do
  options = [
    {
      method: :distribution_data,
      http_method: :get,
      params: {
        search: {
          start_date: '01.22',
          end_date: '09.22',
        },
      },
    },
    {
      method: :growth_rate_data,
      http_method: :get,
      params: {
        search: {
          end_date: '09.22',
          compare_to_end_date: '07.22',
        },
      },
    },
  ]

  it_behaves_like 'Base controller with auth', options
end