require 'webmock/rspec'

RSpec.describe Billing::SendCallback do
  before(:each) do
    VCR.eject_cassette
  end

  specify "#send callback" do
    BASE_URL = Rails.configuration.customization[:eis_billing_system_base_url]

    stub_request(:get, "#{BASE_URL}/api/v1/callback_handler/callback?payment_reference=3434sdfsdfsdf2234234")
      .to_return(status: 200, body: "{\"message\": \"received\"}", headers: {})

    response = described_class.send(reference_number: '3434sdfsdfsdf2234234')

    expect(response["message"].to_s).to eq("received")
  end
end
