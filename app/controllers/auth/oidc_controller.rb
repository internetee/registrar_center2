module Auth
  class OidcController < AuthController
    before_action :require_no_authentication, only: :callback

    # GET /auth/oidc/callback
    def callback
      conn = ApiConnector::Auth::OmniauthChecker.new(username: nil)
      result = conn.call_action(params: oidc_callback_params)
      handle_response(result); return if performed?

      create { user_payload }
    end

    # GET /auth/oidc/cancel
    def cancel
      message_key = params[:message]

      translated = if message_key.present?
        I18n.t("omniauth.errors.#{message_key}", default: message_key.humanize)
      end

      flash[:alert] = translated.presence || t(:sign_in_cancelled)
      redirect_to login_url
    end

    private

    def oidc_callback_params
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
