module Auth
  class SessionsController < AuthController
    before_action :require_no_authentication, only: :new
    before_action :save_ip_address, only: :new
    before_action :verify_signed_out_user, only: :destroy

    def new; end

    def destroy
      sign_out
      redirect_to login_url, notice: I18n.t('auth.sessions.logged_out')
    end

    private

    def auth_params
      params.require(:session).permit(:username, :password)
    end

    def user_payload
      {
        username: auth_params[:username],
        password: auth_params[:password],
        request_ip: cookies[:request_ip] || request.ip,
        requester: 'client',
        user_cert: request.env['HTTP_SSL_CLIENT_CERT'],
        user_cert_cn: request.env['HTTP_SSL_CLIENT_S_DN_CN'],
      }
    end

    def save_ip_address
      cookies[:request_ip] = {
        value: request.ip,
        expires: 1.day.from_now, # Adjust the expiration as needed
        secure: Rails.env.production?, # Set to true for secure cookies in production
        httponly: true
      }
    end
  end
end
