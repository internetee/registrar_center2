require 'rails_helper'

RSpec.feature 'viewing domains' do
  include_context 'Common context with valid login'

  scenario 'with wrong response content type' do
    VCR.use_cassette 'controllers/domains_controller/index-content-type-fail', record: :once do
      visit domains_path
      expect(page).to have_content('Unsupported content type')
    end
  end

  scenario 'with internal server error response' do
    VCR.use_cassette 'controllers/domains_controller/index-internal-server-error', record: :once do
      visit domains_path
      expect(page).to have_content("We're sorry, but something went wrong")
    end
  end

  scenario 'with validation of legal doc types' do
    VCR.use_cassette 'controllers/domains_controller/index', match_requests_on: %i[path method] do
      visit delete_domain_path(domain_name: 'example.ee')
      expect(page).to have_content('Delete domain: example.ee')
      expect(find('#domain_legal_document')['accept']).not_to be_nil
    end
  end

  scenario 'with sorting by name' do
    VCR.use_cassette 'controllers/domains_controller/index', match_requests_on: %i[path method],
                                                             allow_playback_repeats: true do
      visit domains_path
      expect(page).to have_content('New domain added')

      click_link('Name')
      find(:css, '.sort_link', text: /Name/).find(:css, 'i.fas.fa-chevron-down')

      click_link('Name')
      find(:css, '.sort_link', text: /Name/).find(:css, 'i.fas.fa-chevron-up')
    end
  end
end