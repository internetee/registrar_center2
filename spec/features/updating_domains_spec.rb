require 'rails_helper'

RSpec.feature 'updating domains' do
  include_context 'Common context with valid login'

  after do
    VCR.eject_cassette
  end

  scenario 'with response error' do
    VCR.insert_cassette('controllers/domains_controller/edit')
    VCR.insert_cassette('controllers/domains_controller/update-fail')
    VCR.insert_cassette('controllers/domains_controller/show')

    visit edit_domain_path(domain_name: 'example.ee')
    expect(page).to have_content('Edit domain: example.ee')

    click_button('Save')
    expect(page).to have_content('Object status prohibits operation')
    expect(page).to have_current_path(edit_domain_path(domain_name: 'example.ee'))
  end
end