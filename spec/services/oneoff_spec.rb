require 'webmock/rspec'

RSpec.describe Billing::Oneoff do
  before(:each) do
    VCR.eject_cassette
  end

  specify "#send invoice" do
    stub_request(:post, "#{Billing::Connection::BASE_URL}/api/v1/invoice_generator/oneoff")
      .to_return(status: 200, body: "{\"oneoff_redirect_link\": \"everypay/go\"}", headers: {})

    response = described_class.send_invoice(invoice_number: '332211', customer_url: 'http://fake.ee', reference_number: '33322')

    expect(response["oneoff_redirect_link"].to_s).to eq("everypay/go")
  end
end
