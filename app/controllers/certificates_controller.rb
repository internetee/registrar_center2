class CertificatesController < BaseController
  def create
    conn = ApiConnector::Certificates::Creator.new(**auth_info)
    result = conn.call_action(payload: cert_payload)
    handle_response(result, dialog: true); return if performed?

    flash.notice = @message
    redirect_to api_user_path(@response.api_user[:id])
  end

  private

  def cert_params
    params.require(:certificate).permit(:csr, :api_user_id)
  end

  def cert_payload
    {
      csr: transform_file_params(cert_params[:csr]),
      api_user_id: cert_params[:api_user_id],
    }
  end
end
