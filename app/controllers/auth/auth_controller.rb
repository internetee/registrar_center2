module Auth
  class AuthController < ApplicationController
    before_action :require_no_authentication, only: :create

    def create
      auth_info = block_given? ? yield : user_payload
      conn = ApiConnector::Auth::AuthChecker.new(**auth_info)
      result = conn.call_action
      handle_response(result); return if performed?

      uuid = store_auth_info(token: conn.auth_token, data: @response)

      sign_in uuid

      redirect_to dashboard_url, notice: I18n.t('auth.sessions.logged_in')
    end

    def require_no_authentication
      return unless logged_in?

      flash[:alert] = I18n.t('auth.sessions.already_authenticated')
      redirect_back(fallback_location: root_path)
    end

    def verify_signed_out_user
      return if logged_in?

      flash[:alert] = I18n.t('auth.sessions.already_signed_out')
      redirect_to login_url
    end
  end
end
