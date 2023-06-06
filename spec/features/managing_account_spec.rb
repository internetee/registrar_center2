require 'rails_helper'

RSpec.feature 'managing account' do
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
    Rails.cache.clear
  end

  scenario 'as a non-super user' do
    VCR.use_cassette 'signing_in_user/with_epp_role' do
      visit root_path

      fill_in 'Username', with: Rails.configuration.customization[:nonsuper_username]
      fill_in 'Password', with: Rails.configuration.customization[:nonsuper_password]
      click_button 'Sign in'
    end

    VCR.use_cassette 'controllers/account_controller/show', match_requests_on: %i[path method],
                                                            allow_playback_repeats: true do
      visit account_path

      expect(page).to have_content('Api Users')
      expect(page).not_to have_content('Balance Auto-Reload')
      within('#api_users') do
        expect(page).not_to have_link('Add')
        within('.paper--content table tbody') do
          expect(all('tr')).not_to be_empty
          first_row_link = find('tr:first-child a')
          VCR.use_cassette('controllers/api_users/show', match_requests_on: [:method]) do
            first_row_link.click
            expect(page).to have_current_path(account_path)
          end
        end
      end
      within('#white_ips') do
        expect(page).not_to have_link('Add')
      end
    end
  end

  scenario 'as a super user' do
    VCR.use_cassette 'signing_in_user/with_valid_credentials' do
      visit root_path

      fill_in 'Username', with: Rails.configuration.customization[:username]
      fill_in 'Password', with: Rails.configuration.customization[:password]
      click_button 'Sign in'
    end

    VCR.use_cassette 'controllers/account_controller/show', match_requests_on: %i[path method],
                                                            allow_playback_repeats: true do
      visit account_path

      expect(page).to have_content('Api Users')
      expect(page).to have_content('Balance Auto-Reload')
      within('#api_users') do
        expect(page).to have_link('Add')
      end
      within('#white_ips') do
        expect(page).to have_link('Add')
      end
    end
  end
end