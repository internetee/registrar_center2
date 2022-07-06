require 'rails_helper'

RSpec.describe Auth::TaraController, type: :controller do
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
  let(:uuid) { Faker::Internet.uuid }
  let(:username) { Rails.configuration.customization[:username] }
  let(:token) { Rails.configuration.customization[:token] }
  let(:uid) { "EE#{Rails.configuration.customization[:id_code]}" }
  let(:auth_data_legal) { { username: username, token: token } }
  let(:cassette_path) { 'controllers/auth/tara_controller' }
  option = {
    method: :callback,
    http_method: :get,
  }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
    Rails.cache.clear
    request.env['omniauth.auth'] = OmniAuth::AuthHash.new(uid: uid)
  end

  it 'successfully receives callback from tara and logs in user' do
    session[:uuid] = nil
    VCR.use_cassette("#{cassette_path}/#{option[:method]}", match_requests_on: %i[path method]) do
      send(option[:http_method], option[:method], params: option[:params])
    end

    expect([200, 302]).to include response.status
    expect(session[:uuid]).not_to be_nil
    expect(response).to redirect_to(dashboard_path)
  end

  it 'does not receive callback if user already logged in' do
    session[:uuid] = uuid
    Rails.cache.write(uuid, auth_data_legal)
    VCR.use_cassette("#{cassette_path}/#{option[:method]}", match_requests_on: %i[path method]) do
      send(option[:http_method], option[:method], params: option[:params])
    end

    expect([200, 302]).to include response.status
    expect(session[:uuid]).to eq(uuid)
    expect(flash[:alert]).to match(/Already authenticated/)
    expect(response).to redirect_to(root_path)
  end

  it 'redirects to login page when cancel' do
    send(:get, 'cancel')

    expect(response).to redirect_to(login_url)
  end
end