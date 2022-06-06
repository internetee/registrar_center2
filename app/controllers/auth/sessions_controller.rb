module Auth
  class SessionsController < AuthController
    before_action :require_no_authentication, only: %i[new create]
    before_action :verify_signed_out_user, only: :destroy

    def new; end

    def destroy
      sign_out
      redirect_to login_url, notice: I18n.t('auth.sessions.logged_out')
    end

    def switch_user
      conn = ApiConnector::Auth::UserSwitcher.new(**auth_info)
      result = conn.call_action(payload: user_payload)
      handle_response(result); return if performed?

      sign_out
      uuid = store_auth_info(token: @response.token,
                             data: @response.registrar)
      sign_in uuid
      flash.notice = @message
      redirect_to account_path
    end

    private

    def auth_params
      params.require(:session).permit(:username, :password, :user_id)
    end

    def user_payload
      {
        username: auth_params[:username],
        password: auth_params[:password],
        new_user_id: auth_params[:user_id],
      }
    end
  end
end