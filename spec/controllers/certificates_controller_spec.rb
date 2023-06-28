require 'rails_helper'

RSpec.describe CertificatesController, type: :controller do
  file = File.join(Rails.root, '/spec/fixtures/files/csr.csr')
  uploaded_file = Rack::Test::UploadedFile.new(File.open(file))

  options = [
    {
      method: :show,
      http_method: :get,
      params: {
        api_user_id: 22,
        id: 32,
      },
    },
    {
      method: :create,
      http_method: :post,
      params: {
        certificate: {
          csr: uploaded_file,
          api_user_id: 22,
        },
      },
    },
    {
      method: :download,
      http_method: :get,
      params: {
        id: '32',
        api_user_id: '22',
        type: 'csr',
      },
    },
  ]

  it_behaves_like 'Base controller with auth', options
end
