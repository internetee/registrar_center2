require 'rails_helper'

RSpec.feature 'signing in user' do
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
    Rails.cache.clear
  end

  scenario 'with valid credentials', :vcr do
    visit root_path
    expect(page).to have_current_path(login_path)
    expect(page).to have_link('Sign in')

    fill_in 'Username', with: Rails.configuration.customization[:username]
    fill_in 'Password', with: Rails.configuration.customization[:password]
    click_button 'Sign in'

    expect(page).to have_current_path(dashboard_path)
    expect(page).to have_content('Successfully logged in!')
    expect(page).to have_link('Sign out')
  end

  scenario 'with invalid credentials', :vcr do
    visit root_path

    fill_in 'Username', with: Rails.configuration.customization[:username]
    fill_in 'Password', with: Rails.configuration.customization[:password]
    click_button 'Sign in'

    expect(page).to have_current_path(login_path)
    expect(page).to have_content('Invalid authorization information')
    expect(page).to have_link('Sign in')
  end
end