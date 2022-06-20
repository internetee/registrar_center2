require 'rails_helper'

RSpec.feature 'signing out user' do
  include_context 'Common context with valid login'

  scenario 'with sign out link' do
    VCR.use_cassette cassette do
      visit root_path
      expect(page).to have_current_path(root_path)
      expect(page).to have_link('Sign out')

      click_link 'Sign out', match: :first
      expect(page).to have_content('Logged out!')
      expect(page).to have_current_path(login_path)
      expect(page).not_to have_link('Sign out')

      visit logout_path
      expect(page).to have_content('Already signed out!')
      expect(page).to have_current_path(login_path)
    end
  end

  scenario 'with expired or missing auth info' do
    Rails.cache.clear
    visit root_path
    expect(page).to have_current_path(login_path)
    expect(page).to have_link('Sign in')
  end
end