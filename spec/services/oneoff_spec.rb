require 'webmock/rspec'

RSpec.describe Billing::Oneoff do
  before(:each) do
    VCR.eject_cassette
  end

  specify "#send invoice" do
    BASE_URL = Rails.configuration.customization[:eis_billing_system_base_url]

    stub_request(:post, "#{BASE_URL}/api/v1/invoice_generator/oneoff")
      .to_return(status: 200, body: "{\"oneoff_redirect_link\": \"everypay/go\"}", headers: {})

    response = described_class.send_invoice(invoice_number: '332211', customer_url: 'http://fake.ee')

    expect(response["oneoff_redirect_link"].to_s).to eq("everypay/go")
  end
end
