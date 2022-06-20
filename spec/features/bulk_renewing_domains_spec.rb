require 'rails_helper'

RSpec.feature 'bulk renewing domains' do
  include_context 'Common context with valid login'

  scenario 'with missing expire date' do
    visit new_domain_bulk_change_path
    find('#bulk_change_type').find(:option, 'Renew domains').select_option
    click_button 'Next step'

    click_button 'Filter'
    expect(page).to have_content('Missing parameters: Expire date')
  end

  scenario 'with testing valid bulk change cache' do
    visit new_domain_bulk_change_path
    find('#bulk_change_type').find(:option, 'Renew domains').select_option
    click_button 'Next step'

    expect(page).to have_button('Filter')
    session = Capybara.current_session.driver.request.session
    expect(Rails.cache.exist?(session.id)).to be(true)

    VCR.use_cassette('controllers/dashboard_controller/index') do
      visit dashboard_path
    end

    visit new_domain_bulk_change_path
    expect(page).to have_button('Filter')
    expect(page).to have_current_path(/input_data/)
  end

  scenario 'with selected domains list', :vcr do
    visit new_domain_bulk_change_path
    find('#bulk_change_type').find(:option, 'Renew domains').select_option
    click_button 'Next step'

    click_button 'Filter'
    expect(page).to have_content('Missing parameters: Expire date')

    fill_in 'bulk_change_expire_date', with: '2022-11-30'
    click_button 'Filter'
    expect(page).to have_content('Choose domains you want to renew')

    click_button 'Next step'
    expect(page).to have_current_path(/make_changes/)
    expect(page).to have_content('Please confirm you want to renew')
  end
end