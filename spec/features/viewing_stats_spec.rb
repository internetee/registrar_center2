require 'rails_helper'

RSpec.feature 'viewing statistics' do
  include_context 'Common context with valid login'

  scenario 'distribution with searching by start date' do
    cassette = 'controllers/stats/market_share_controller/distribution_data'
    VCR.use_cassette cassette, match_requests_on: %i[path method] do
      visit market_share_path
      expect(page).to have_content('Stats')

      page.fill_in 'search_start_date', with: '01.22'

      click_button('Filter')
      expect(page).to have_current_path(/search\[start_date\]=01.22/)
    end
  end

  scenario 'growth rate with searching by comparison date' do
    cassette = 'controllers/stats/market_share_controller/growth_rate_data'
    VCR.use_cassette cassette, match_requests_on: %i[path method] do
      visit market_share_path(type: 'growth_rate')
      expect(page).to have_content('Stats')

      page.fill_in 'search_compare_to_date', with: '07.22'

      click_button('Filter')
      expect(page).to have_current_path(/search\[compare_to_date\]=07.22/)
    end
  end
end