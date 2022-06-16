require 'rails_helper'

RSpec.feature 'updating domain' do
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

    VCR.insert_cassette('controllers/domains_controller/edit')
    VCR.insert_cassette('controllers/domains_controller/show')
  end

  scenario 'with valid attributes' do
    visit edit_domain_path(domain_name: 'example.ee')
    expect(page).to have_content('Edit domain: example.ee')
    VCR.use_cassette('controllers/domains_controller/update-fail', match_requests_on: %i[path method]) do
      click_button 'Save'
    end

    expect(page).to have_current_path(edit_domain_path(domain_name: 'example.ee'))
  end
end