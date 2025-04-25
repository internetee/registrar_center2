module Certificates
  class P12Controller < BaseController
    def create
      conn = ApiConnector::Certificates::P12::Creator.new(**auth_info)
      result = conn.call_action(payload: p12_payload)
      handle_response(result); return if performed?

      flash.notice = @message
      redirect_to api_user_path(params[:api_user_id])
    end

    private

    def p12_payload
      {
        api_user_id: params[:api_user_id]
      }
    end
  end
end
