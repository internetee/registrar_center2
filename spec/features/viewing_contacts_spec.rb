require 'rails_helper'

RSpec.feature 'viewing contacts' do
  include_context 'Common context with valid login'

  scenario 'with searching by country' do
    VCR.use_cassette 'controllers/contacts_controller/index', match_requests_on: %i[path method],
                                                              allow_playback_repeats: true do
      visit contacts_path

      click_button('Open filter')
      find('#search_country_code_eq').find(:option, 'Estonia', match: :first).select_option

      click_button('Filter')
      expect(page).to have_current_path(/search\[country_code_eq\]=EE/)
    end
  end
end