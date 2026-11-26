require 'rails_helper'

RSpec.describe ApiUsersController, type: :controller do
  options = [
    {
      method: :index,
      http_method: :get,
      format: :csv,
    },
    {
      method: :show,
      http_method: :get,
      params: {
        id: 2,
      },
    },
    {
      method: :create,
      http_method: :post,
      params: {
        api_user: {
          username: Faker::Internet.username,
          password: Faker::Internet.password,
          subject: "EE#{Faker::Number.unique.number(digits: 11)}",
          roles: 'super',
          active: 'true',
        },
      },
    },
    {
      method: :update,
      http_method: :put,
      params: {
        id: '2',
        api_user: {
          id: '2',
          username: Faker::Internet.username,
          password: Faker::Internet.password,
          subject: "EE#{Faker::Number.unique.number(digits: 11)}",
          roles: 'super',
          active: 'false',
        },
      },
    },
    {
      method: :destroy,
      http_method: :delete,
      params: {
        id: 18,
      },
    },
  ]

  it_behaves_like 'Base controller with auth', options
end

RSpec.describe ApiUsersController, type: :controller do
  describe 'POST #approve_verification' do
    let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
    let(:uuid) { Faker::Internet.uuid }
    let(:auth_data) do
      { username: Rails.configuration.customization[:username],
        token: Rails.configuration.customization[:token] }
    end
    let(:connector) { instance_double(ApiConnector::ApiUsers::VerificationApprover) }
    let(:success) do
      OpenStruct.new(success: true, type: 'application/json',
                     body: { code: 1000, message: 'Command completed successfully', data: {} })
    end

    before do
      allow(Rails).to receive(:cache).and_return(memory_store)
      session[:uuid] = uuid
      Rails.cache.write(uuid, Encryptor.encrypt(auth_data.to_json))
      allow(ApiConnector::ApiUsers::VerificationApprover).to receive(:new).and_return(connector)
    end

    it 'sends an empty payload when no subject is given' do
      expect(connector).to receive(:call_action).with(id: '2', payload: {}).and_return(success)

      post :approve_verification, params: { id: '2' }

      expect(response).to redirect_to(api_user_path('2'))
    end

    it 'sends a composed subject when country code and identity number are given' do
      expect(connector).to receive(:call_action)
        .with(id: '2', payload: { api_user: { subject: 'EE38001085718' } })
        .and_return(success)

      post :approve_verification,
           params: { id: '2', api_user: { country_code: 'ee', identity_number: '38001085718' } }

      expect(response).to redirect_to(api_user_path('2'))
    end
  end
end
