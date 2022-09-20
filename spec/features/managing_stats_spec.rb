require 'rails_helper'

RSpec.feature 'managing statistics' do
  include_context 'Common context with valid login'

  scenario 'by viewing market share distribution with searching by start date' do
    cassette = 'controllers/stats/market_share_controller/distribution_data'
    VCR.use_cassette cassette, match_requests_on: %i[path method] do
      visit market_share_path
      expect(page).to have_content('Stats')

      page.fill_in 'search_start_date', with: '01.22'
      page.fill_in 'search_end_date', with: '09.22'

      click_button('Filter')
      expect(page).to have_current_path(/search\[start_date\]=01.22/)
    end
  end

  scenario 'by viewing market share growth rate with searching by comparison date' do
    cassette = 'controllers/stats/market_share_controller/growth_rate_data'
    VCR.use_cassette cassette, match_requests_on: %i[path method] do
      visit market_share_path(type: 'growth_rate')
      expect(page).to have_content('Stats')

      page.fill_in 'search_compare_to_date', with: '07.22'

      click_button('Filter')
      expect(page).to have_current_path(/search\[compare_to_date\]=07.22/)
    end
  end

  scenario 'by downloading csv file of market share distribution' do
    cassette = 'controllers/stats/market_share_controller/distribution_data'
    VCR.use_cassette cassette, match_requests_on: %i[path method] do
      visit market_share_path(type: 'distribution')
      expect(page).to have_content('Stats')

      page.fill_in 'search_start_date', with: '01.22'
      page.fill_in 'search_end_date', with: '09.22'

      click_link('Download CSV')
      expect(response_headers['Content-Disposition']).to have_content('attachment')
      expect(page.body).to have_content('Sep, 2022')
      expect(page).to have_current_path(%r{stats/market_share/distribution.csv})
    end
  end

  scenario 'by downloading csv file of market share growth rate' do
    cassette = 'controllers/stats/market_share_controller/growth_rate_data'
    VCR.use_cassette cassette, match_requests_on: %i[path method] do
      visit market_share_path(type: 'growth_rate')
      expect(page).to have_content('Stats')

      page.fill_in 'search_compare_to_date', with: '07.22'

      click_link('Download CSV')
      expect(response_headers['Content-Disposition']).to have_content('attachment')
      expect(page.body).to have_content('Sep, 2022')
      expect(page).to have_current_path(%r{stats/market_share/growth_rate.csv})
    end
  end
end