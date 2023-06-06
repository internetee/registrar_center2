require 'rails_helper'

RSpec.feature 'viewing api user' do
  include_context 'Common context with valid login'

  scenario 'with super user' do
    VCR.use_cassette('controllers/api_users_controller/show', match_requests_on: [:method]) do
      visit api_user_path(id: 2)
      expect(page).to have_content('Details')
      expect(page).to have_content('Certificates')
    end
  end
end