module Auth
  class TaraController < AuthController
    before_action :require_no_authentication, only: :callback

    def callback
      conn = ApiConnector::Auth::OmniauthTaraChecker.new(username: nil)
      result = conn.call_action(params: tara_callback_params)
      handle_response(result); return if performed?

      create { user_payload }
    end

    def cancel
      redirect_to login_url
    end

    private

    def tara_callback_params
      {
        auth: {
          uid: omniauth_user_hash.try(:uid),
        },
      }
    end

    def user_payload
      {
        username: @response.username,
        token: @response.token,
        request_ip: cookies[:request_ip] || request.ip,
        requester: 'tara'
      }
    end

    def omniauth_user_hash
      request.env['omniauth.auth']&.delete_if { |key, _| key == 'credentials' }
    end
  end
end
