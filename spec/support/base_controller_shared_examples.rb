RSpec.shared_examples 'Base controller with auth' do |options|
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
  let(:uuid) { Faker::Internet.uuid }
  let(:username) { Rails.configuration.customization[:username] }
  let(:username_fail) { Faker::Lorem.word }
  let(:password) { Rails.configuration.customization[:password] }
  let(:password_fail) { Faker::Internet.password }
  let(:token) { Rails.configuration.customization[:token] }
  let(:token_fail) { Base64.urlsafe_encode64("#{username_fail}:#{password_fail}") }
  let(:auth_data_legal) { { username: username, token: token } }
  let(:auth_data_fail) { { username: username, token: token_fail } }
  let(:cassette_path) { "controllers/#{described_class.to_s.underscore}" }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
    Rails.cache.clear
  end

  options.each do |option|
    it 'successfully checks for auth info in session' do
      session[:uuid] = uuid
      Rails.cache.write(uuid, auth_data_legal)
      VCR.use_cassette("#{cassette_path}/#{option[:method]}", match_requests_on: %i[path method]) do
        # p VCR.current_cassette.file
        send(option[:http_method], option[:method], params: option[:params])
      end

      expect([200, 302]).to include response.status
      expect(response).not_to redirect_to(login_path)
    end

    it 'redirects if no uuid in session' do
      session[:uuid] = nil
      send(option[:http_method], option[:method], params: option[:params])

      expect(response).to redirect_to(login_path)
    end

    it 'redirects if no auth data stored' do
      session[:uuid] = uuid
      send(option[:http_method], option[:method], params: option[:params])

      expect(response).to redirect_to(login_path)
    end

    it 'redirects to auth controller if failed auth' do
      session[:uuid] = uuid
      Rails.cache.write(uuid, auth_data_fail)
      VCR.use_cassette("#{cassette_path}/#{option[:method]}-auth-fail", match_requests_on: %i[path method]) do
        # p VCR.current_cassette.file
        send(option[:http_method], option[:method], params: option[:params])
      end

      expect(response).to redirect_to(login_path)
    end
  end
end
