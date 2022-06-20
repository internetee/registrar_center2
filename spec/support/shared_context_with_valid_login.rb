RSpec.shared_context 'Common context with valid login' do
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
end