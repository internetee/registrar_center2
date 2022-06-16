require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  options = [
    {
      method: :index,
      http_method: :get,
    },
  ]

  it_behaves_like 'Base controller with auth', options
end