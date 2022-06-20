require 'rails_helper'

RSpec.feature 'bulk changing registrar' do
  include_context 'Common context with valid login'

  after do
    VCR.eject_cassette
  end

  scenario 'with valid batch file uploaded' do
    visit new_domain_bulk_change_path
    find('#bulk_change_type').find(:option, 'Replace registrar').select_option
    click_button 'Next step'
    expect(page).to have_content('Upload CSV file')

    VCR.insert_cassette('controllers/domains_controller/transfer', match_requests_on: %i[path method])
    VCR.insert_cassette('controllers/domains_controller/index', match_requests_on: %i[path method])

    find('form input[type="file"]').set("#{Rails.root}/spec/fixtures/files/bulk_domain_transfer.csv")
    click_button 'Next step'
    expect(page).to have_content('Please confirm')

    click_button 'Confirm'
    expect(page).to have_content('successfully transferred')
    expect(page).to have_current_path(domains_path)
  end
end