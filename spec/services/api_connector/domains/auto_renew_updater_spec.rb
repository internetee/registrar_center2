require 'rails_helper'

RSpec.describe ApiConnector::Domains::AutoRenewUpdater do
  let(:connector) { described_class.new(username: 'registrar', token: 'token') }
  let(:url) { "#{ENV['REPP_HOST']}#{ENV['REPP_ENDPOINT']}/domains/example.ee/auto_renew" }

  before { VCR.eject_cassette }

  [true, false].each do |enabled|
    it "sends the explicit preference #{enabled} without a cycle ID" do
      request = stub_request(:put, url)
                .with(body: { auto_renew: { enabled: enabled }, locale: I18n.locale }.to_json)
                .to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                           body: { code: 1000, data: { auto_renew: { enabled: enabled } } }.to_json)

      expect(connector.call_action(payload: { name: 'example.ee', enabled: enabled }).success).to be true
      expect(request).to have_been_requested.once
    end
  end

  it 'sends the displayed cycle ID for a refund and returns registry errors' do
    request = stub_request(:put, url)
              .with(body: { auto_renew: { enabled: false, cycle_id: 'displayed-cycle' },
                            locale: I18n.locale }.to_json)
              .to_return(status: 400, headers: { 'Content-Type' => 'application/json' },
                         body: { code: 2304, message: 'Cancellation deadline passed', data: {} }.to_json)

    result = connector.call_action(payload: { name: 'example.ee', enabled: false, cycle_id: 'displayed-cycle' })

    expect(result.success).to be false
    expect(result.body[:code]).to eq(2304)
    expect(result.body[:message]).to eq('Cancellation deadline passed')
    expect(request).to have_been_requested.once
  end
end
