require 'rails_helper'

RSpec.feature 'signing in user' do
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
  let(:cassette) { 'signing_in_user/with_valid_credentials' }

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

    VCR.use_cassette cassette do
      visit login_path
      expect(page).to have_content('Already authenticated!')
      expect(page).to have_current_path(root_path)
    end
  end

  scenario 'with invalid credentials', :vcr do
    visit root_path

    fill_in 'Username', with: Faker::Lorem.word
    fill_in 'Password', with: Faker::Internet.password
    click_button 'Sign in'

    expect(page).to have_current_path(login_path)
    expect(page).to have_content('Invalid authorization information')
    expect(page).to have_link('Sign in')
  end

  scenario 'with epp role', :vcr do
    visit root_path
    expect(page).to have_current_path(login_path)
    expect(page).to have_link('Sign in')

    fill_in 'Username', with: Rails.configuration.customization[:epp_username]
    fill_in 'Password', with: Rails.configuration.customization[:epp_password]
    click_button 'Sign in'

    expect(page).to have_current_path(dashboard_path)
    expect(page).to have_content('Successfully logged in!')
    expect(page).to have_link('Sign out')
  end
end