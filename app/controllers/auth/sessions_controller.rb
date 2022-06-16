module Auth
  class SessionsController < AuthController
    before_action :require_no_authentication, only: %i[new create]
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
      }
    end
  end
end