module Auth
  class TaraController < AuthController
    before_action :require_no_authentication, only: %i[callback]

    def callback
      conn = ApiConnector::Auth::OmniauthTaraChecker.new(username: nil)
      result = conn.call_action(payload: tara_payload)
      handle_response(result); return if performed?

      create do
        { username: @response.username, token: @response.token, request_ip: cookies[:ip_address] }
      end
    end

    def cancel
      redirect_to login_url
    end

    private

    def tara_payload
      {
        auth: {
          uid: omniauth_user_hash.try(:uid),
        },
      }
    end

    def omniauth_user_hash
      request.env['omniauth.auth']&.delete_if { |key, _| key == 'credentials' }
    end
  end
end
