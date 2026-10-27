require 'rails_helper'

RSpec.describe DomainsController, type: :controller do
  let(:base_url) { "#{ENV['REPP_HOST']}#{ENV['REPP_ENDPOINT']}" }
  let(:domain_url) { "#{base_url}/domains/example.ee" }
  let(:domain) do
    { name: 'example.ee', registrant: { code: 'contact-id', name: 'Registrant' },
      contacts: [], nameservers: [], dnssec_keys: [], auto_renew: { enabled: true, cycle: nil } }
  end

  def repp_response(data = {}, code: 1000, message: 'Command completed successfully', status: 200, **fields)
    { status: status, headers: { 'Content-Type' => 'application/json' },
      body: { code: code, message: message, data: data.merge(fields) }.to_json }
  end

  before do
    VCR.eject_cassette
    allow(controller).to receive(:auth_info).and_return(username: 'registrar', token: 'token')
  end

  it 'defaults new domains to automatic renewal disabled' do
    allow(controller).to receive(:authorize!)
    get :new
    expect(controller.view_assigns.fetch('domain_params')[:auto_renew]).to be false
  end

  [true, false].each do |enabled|
    it "hydrates the edit preference #{enabled} from REPP info" do
      domain[:auto_renew][:enabled] = enabled
      stub_request(:get, domain_url).with(query: hash_including('locale' => 'en'))
        .to_return(repp_response(domain: domain))

      get :edit, params: { domain_name: domain[:name] }

      expect(controller.view_assigns.fetch('domain_params')[:auto_renew]).to eq(enabled)
    end

    it "permits and sends create preference #{enabled}" do
      request = stub_request(:post, "#{base_url}/domains").with do |req|
        JSON.parse(req.body).dig('domain', 'auto_renew') == enabled
      end.to_return(repp_response(domain: domain))

      post :create, params: { domain: { name: domain[:name], registrant: { code: 'contact-id' },
                                       period: '1y', auto_renew: enabled.to_s } }

      expect(request).to have_been_requested.once
      expect(response).to redirect_to(domain_path(domain_name: domain[:name]))
    end

    it "sends a changed preference #{enabled} only through the nested endpoint" do
      domain[:auto_renew][:enabled] = !enabled
      stub_request(:get, domain_url).with(query: hash_including('locale' => 'en'))
        .to_return(repp_response(domain: domain))
      full_update = stub_request(:put, domain_url).with do |req|
        !JSON.parse(req.body).fetch('domain').key?('auto_renew')
      end.to_return(repp_response(domain: domain))
      preference_update = stub_request(:put, "#{domain_url}/auto_renew")
                          .with(body: { auto_renew: { enabled: enabled }, locale: 'en' }.to_json)
                          .to_return(repp_response(domain: domain[:name], auto_renew: { enabled: enabled }))

      post :update, params: { domain: { name: domain[:name], auto_renew: enabled.to_s } }

      expect(full_update).to have_been_requested.once
      expect(preference_update).to have_been_requested.once
      expect(response).to redirect_to(domain_path(domain_name: domain[:name]))
      expect(flash[:notice]).to eq('Command completed successfully')
    end
  end

  it 'does not send an unchanged preference' do
    stub_request(:get, domain_url).with(query: hash_including('locale' => 'en'))
      .to_return(repp_response(domain: domain))
    stub_request(:put, domain_url).to_return(repp_response(domain: domain))

    post :update, params: { domain: { name: domain[:name], auto_renew: 'true' } }

    expect(WebMock).not_to have_requested(:put, "#{domain_url}/auto_renew")
  end

  it 'preserves an uploaded legal document while comparing the preference' do
    stub_request(:get, domain_url).with(query: hash_including('locale' => 'en'))
      .to_return(repp_response(domain: domain))
    document_path = Rails.root.join('spec/fixtures/files/legal_doc.pdf')
    document = Rack::Test::UploadedFile.new(document_path, 'application/pdf')
    full_update = stub_request(:put, domain_url).with do |req|
      encoded_document = JSON.parse(req.body).dig('domain', 'legal_document', 'body')
      Base64.decode64(encoded_document) == File.binread(document_path)
    end.to_return(repp_response(domain: domain))
    stub_request(:put, "#{domain_url}/auto_renew").to_return(repp_response(domain: domain[:name]))

    post :update, params: { domain: { name: domain[:name], auto_renew: 'false', legal_document: document } }

    expect(full_update).to have_been_requested.once
  end

  it 'does not update anything when the preference cannot be read' do
    stub_request(:get, domain_url).with(query: hash_including('locale' => 'en'))
      .to_return(repp_response({}, code: 2303, message: 'Domain not found', status: 404))

    post :update, params: { domain: { name: domain[:name], auto_renew: 'false' } }

    expect(WebMock).not_to have_requested(:put, domain_url)
    expect(WebMock).not_to have_requested(:put, "#{domain_url}/auto_renew")
    expect(flash[:alert]).to eq('Domain not found')
  end

  it 'leaves an omitted preference unchanged without fetching info' do
    stub_request(:put, domain_url).to_return(repp_response(domain: domain))

    post :update, params: { domain: { name: domain[:name] } }

    expect(WebMock).not_to have_requested(:get, domain_url).with(query: hash_including('locale' => 'en'))
    expect(WebMock).not_to have_requested(:put, "#{domain_url}/auto_renew")
  end

  it 'does not change the preference if the full domain update fails' do
    stub_request(:get, domain_url).with(query: hash_including('locale' => 'en'))
      .to_return(repp_response(domain: domain))
    stub_request(:put, domain_url)
      .to_return(repp_response({}, code: 2304, message: 'Object status prohibits operation', status: 400))

    post :update, params: { domain: { name: domain[:name], auto_renew: 'false' } }

    expect(WebMock).not_to have_requested(:put, "#{domain_url}/auto_renew")
    expect(flash[:alert]).to eq('Object status prohibits operation')
  end

  it 'shows errors from the preference endpoint on edit' do
    stub_request(:get, domain_url).with(query: hash_including('locale' => 'en'))
      .to_return(repp_response(domain: domain))
    stub_request(:put, domain_url).to_return(repp_response(domain: domain))
    stub_request(:put, "#{domain_url}/auto_renew")
      .to_return(repp_response({}, code: 2306, message: 'Automatic renewal is not available', status: 400))

    post :update, params: { domain: { name: domain[:name], auto_renew: 'false' } }

    expect(flash[:alert]).to eq('Automatic renewal is not available')
    expect(flash[:notice]).to be_nil
  end

  it 'submits the explicit displayed cycle ID and shows a successful refund notice' do
    request = stub_request(:put, "#{domain_url}/auto_renew")
              .with(body: { auto_renew: { enabled: 'false', cycle_id: 'displayed-cycle' }, locale: 'en' }.to_json)
              .to_return(repp_response({ domain: domain[:name] }, message: 'Renewal reversed and refunded'))

    put :update_auto_renew, params: { domain_name: domain[:name],
                                     auto_renew: { enabled: 'false', cycle_id: 'displayed-cycle' } }

    expect(request).to have_been_requested.once
    expect(response).to redirect_to(domain_path(domain_name: domain[:name]))
    expect(flash[:notice]).to eq('Renewal reversed and refunded')
  end

  it 'displays a registry deadline error without a success notice' do
    return_path = domain_path(domain_name: domain[:name])
    request.env['HTTP_REFERER'] = return_path
    stub_request(:put, "#{base_url}/domains/example.ee/auto_renew")
      .to_return(repp_response({}, code: 2304, message: 'Cancellation deadline passed', status: 400))

    put :update_auto_renew, params: { domain_name: domain[:name],
                                     auto_renew: { enabled: 'false', cycle_id: 'displayed-cycle' } }

    expect(response).to redirect_to(return_path)
    expect(flash[:alert]).to eq('Cancellation deadline passed')
    expect(flash[:notice]).to be_nil
  end

  it 'forwards all automatic renewal filters under q to REPP' do
    filters = { auto_renew_eq: 'true', auto_renew_grace: 'true', auto_renew_funding_retry: 'true' }
    request = stub_request(:get, "#{base_url}/domains")
              .with(query: hash_including('q' => filters.stringify_keys))
              .to_return(repp_response(statuses: [], domains: [], count: 0, new_domain: []))

    get :index, params: { search: filters }

    expect(request).to have_been_requested.once
  end
end
