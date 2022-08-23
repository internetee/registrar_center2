require 'rails_helper'

RSpec.describe InvoicesController, type: :controller do
  options = [
    {
      method: :index,
      http_method: :get,
      params: {
        search: {
          invoice_status: 'account_activity_id_not_null',
        },
      },
    },
    {
      method: :show,
      http_method: :get,
      params: {
        id: 41,
      },
      format: :pdf,
    },
    {
      method: :download,
      http_method: :get,
      params: {
        id: 41,
      },
    },
    {
      method: :send_to_recipient,
      http_method: :post,
      params: {
        invoice: {
          recipient: Faker::Internet.email,
          id: 41,
        },
      },
    },
    {
      method: :cancel,
      http_method: :post,
      params: {
        invoice: {
          id: 41,
        },
      },
    },
    {
      method: :add_credit,
      http_method: :post,
      params: {
        invoice: {
          amount: 100,
          description: Faker::Lorem.sentence,
        },
      },
    }
  ]

  it_behaves_like 'Base controller with auth', options

  describe 'billing connection' do
    before(:each) do  
      allow_any_instance_of(BaseController).to receive(:check_auth_info).and_return(true)
    end

    describe 'successful oneoff redirection' do
      redirect_link = "http://everypay.ee/go"
      oneoff_payload = {
        oneoff_redirect_link: redirect_link
      }

      subject do
        stub_request(:post, "#{Billing::Connection::BASE_URL}/api/v1/invoice_generator/oneoff")
        .to_return(status: 200, body: oneoff_payload.to_json, headers: {})

        post :pay, params: { invoice_number: '2332434 '}
      end

      it 'should redirect to everypay payment dialog if oneoff link has been received' do
        expect(subject).to redirect_to(redirect_link)
      end
    end

    describe 'oneoff response with error' do
      error_message = {
        error: {
          message: "Something goes wrong"
        }
      }

      subject do
        stub_request(:post, "#{Billing::Connection::BASE_URL}/api/v1/invoice_generator/oneoff")
        .to_return(status: 200, body: error_message.to_json, headers: {})

        post :pay, params: { invoice_number: '2332434 '}
      end

      it 'should redirect to invoices_path if comes error from billing' do
        expect(subject).to redirect_to(invoices_path)
      end
    end

    describe 'callback from everypay' do
      payment_reference = '223344abc'
      message = {
        message: true
      }

      subject do
        stub_request(:get, "#{Billing::Connection::BASE_URL}/api/v1/callback_handler/callback?payment_reference=#{payment_reference}")
        .to_return(status: 200, body: message.to_json, headers: {})

        get :callback, params: { payment_reference: payment_reference }
      end

      it 'should redirect everypay callback to billing callback handler and redirected to invoices list' do
        expect(subject).to redirect_to(invoices_path)
      end
    end
  end
end
