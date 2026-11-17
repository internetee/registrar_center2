require 'rails_helper'

RSpec.describe ApiConnector::Domains::Creator do
  let(:connector) { described_class.new(username: 'registrar', token: 'token') }
  let(:payload) do
    { name: 'example.ee', registrant: { code: 'contact-id' }, period: '1y', nameservers: [],
      contacts: [], dns_keys: [] }
  end

  before { VCR.eject_cassette }

  [true, false, nil].each do |preference|
    it "maps the create preference #{preference.inspect} to domain[auto_renew]" do
      request = stub_request(:post, "#{ENV['REPP_HOST']}#{ENV['REPP_ENDPOINT']}/domains")
                .with do |req|
        domain = JSON.parse(req.body).fetch('domain')
        domain['auto_renew'] == (preference == true) && domain['name'] == 'example.ee'
      end.to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                    body: { code: 1000, data: { domain: { name: 'example.ee' } } }.to_json)

      payload[:auto_renew] = preference unless preference.nil?
      expect(connector.call_action(payload: payload).success).to be true
      expect(request).to have_been_requested.once
    end
  end
end
