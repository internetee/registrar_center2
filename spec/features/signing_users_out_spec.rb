require 'rails_helper'

RSpec.feature 'signing out signed in user' do
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
  let(:cassette) { 'signing_in_user/with_valid_credentials' }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
    Rails.cache.clear

    VCR.use_cassette cassette do
      visit root_path

      fill_in 'Username', with: Rails.configuration.customization[:username]
      fill_in 'Password', with: Rails.configuration.customization[:password]
      click_button 'Sign in'
    end
  end

  scenario 'with sign out link' do
    VCR.use_cassette cassette do
      visit root_path
      expect(page).to have_current_path(root_path)
      expect(page).to have_link('Sign out')

      click_link 'Sign out', match: :first
      expect(page).to have_content('Logged out!')
      expect(page).to have_current_path(login_path)
      expect(page).not_to have_link('Sign out')
    end
  end

  scenario 'with expired or missing auth info' do
    Rails.cache.clear
    visit root_path
    expect(page).to have_current_path(login_path)
    expect(page).to have_link('Sign in')
  end
end