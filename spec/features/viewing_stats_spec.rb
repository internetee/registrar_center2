require 'rails_helper'

RSpec.feature 'viewing statistics' do
  include_context 'Common context with valid login'

  scenario 'with searching by start date' do
    cassette = 'controllers/stats/market_share_controller/domains_by_registrar'
    VCR.use_cassette cassette, match_requests_on: %i[path method] do
      visit stats_market_share_index_path
      expect(page).to have_content('Stats')

      page.fill_in 'search_start_date', with: '01.22'

      click_button('Filter')
      expect(page).to have_current_path(/search\[start_date\]=01.22/)
    end
  end
end