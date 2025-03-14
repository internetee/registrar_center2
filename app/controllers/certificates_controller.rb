class CertificatesController < BaseController
  def show
    conn = ApiConnector::Certificates::Reader.new(**auth_info)
    result = conn.call_action(api_user_id: params[:api_user_id], id: params[:id])
    handle_response(result); return if performed?

    @certificate = @response.cert
  end

  def create
    conn = ApiConnector::Certificates::Creator.new(**auth_info)
    result = conn.call_action(payload: cert_payload)
    handle_response(result, dialog: true); return if performed?

    flash.notice = @message
    redirect_to api_user_path(@response.api_user[:id])
  end

  def download
    conn = ApiConnector::Certificates::Downloader.new(**auth_info)
    result = conn.call_action(api_user_id: params[:api_user_id], id: params[:id], type: params[:type])
    handle_response(result); return if performed?

    send_data @response, filename: @message.match(/filename=(\"?)(.+)\1/)[2]
  end

  def renew
    conn = ApiConnector::Certificates::Renewer.new(**auth_info)
    result = conn.call_action(api_user_id: params[:api_user_id], id: params[:id])
    handle_response(result); return if performed?

    flash.notice = @message
    redirect_to api_user_path(params[:api_user_id])
  end

  def revoke
    conn = ApiConnector::Certificates::Revoker.new(**auth_info)
    result = conn.call_action(api_user_id: params[:api_user_id], id: params[:id])
    handle_response(result); return if performed?

    flash.notice = @message
    redirect_to api_user_path(params[:api_user_id])
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
