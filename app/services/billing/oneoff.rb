module Billing
  class Oneoff
    include Billing::Request
    attr_reader :invoice_number, :customer_url, :reference_number

    def initialize(invoice_number:, customer_url:, reference_number:)
      @invoice_number = invoice_number
      @customer_url = customer_url
      @reference_number = reference_number
    end

    def self.send_invoice(invoice_number:, customer_url:, reference_number:)
      fetcher = new(invoice_number: invoice_number, customer_url: customer_url, reference_number: reference_number)
      fetcher.send_it
    end

    def send_it
      post invoice_oneoff_url, params
    end

    def params
      { invoice_number: invoice_number,
        customer_url: customer_url,
        reference_number: reference_number }
    end

    def invoice_oneoff_url
      '/api/v1/invoice_generator/oneoff'
    end
  end
end
