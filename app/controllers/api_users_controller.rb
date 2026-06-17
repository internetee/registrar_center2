class ApiUsersController < BaseController
  def index
    conn = ApiConnector::ApiUsers::All.new(**auth_info)
    result = conn.call_action(limit: nil, offset: nil)
    handle_response(result); return if performed?

    @api_users = @response.users
    respond_to do |format|
      format.csv { format_csv }
    end
  end

  def show
    conn = ApiConnector::ApiUsers::Reader.new(**auth_info)
    result = conn.call_action(id: params[:id])
    handle_response(result); return if performed?

    @api_user = @response.user
    @roles = @response.roles
  end

  def create
    conn = ApiConnector::ApiUsers::Creator.new(**auth_info)
    result = conn.call_action(payload: api_user_payload)
    handle_response(result, dialog: true); return if performed?

    flash.notice = @message
    redirect_to api_user_path(@response.api_user[:id])
  end

  def update
    conn = ApiConnector::ApiUsers::Updater.new(**auth_info)
    result = conn.call_action(payload: api_user_payload)
    handle_response(result, dialog: true); return if performed?

    if changed_own_password?
      sign_out
      redirect_to login_url, notice: t('auth.sessions.password_changed_sign_in_again')
      return
    end

    flash.notice = @message
    redirect_to api_user_path(@response.api_user[:id])
  end

  def destroy
    conn = ApiConnector::ApiUsers::Deleter.new(**auth_info)
    result = conn.call_action(id: params[:id])
    handle_response(result); return if performed?

    flash.notice = @message
    redirect_to account_path
  end

  def verify
    conn = ApiConnector::ApiUsers::Verifier.new(**auth_info)
    result = conn.call_action(id: params[:id])
    handle_response(result); return if performed?

    flash.notice = @message
    redirect_to api_user_path(params[:id])
  end

  def download_poi
    conn = ApiConnector::ApiUsers::PoiDownloader.new(**auth_info)
    result = conn.call_action(id: params[:id])
    handle_response(result); return if performed?

    send_data(@response, type: 'application/pdf',
                         disposition: 'attachment',
                         filename: @message.match(/filename=(\"?)(.+)\1/)[2])
  end

  def approve_verification
    conn = ApiConnector::ApiUsers::VerificationApprover.new(**auth_info)
    result = conn.call_action(id: params[:id], payload: approve_verification_payload)
    handle_response(result); return if performed?

    flash.notice = @message
    redirect_to api_user_path(params[:id])
  end

  def reject_verification
    conn = ApiConnector::ApiUsers::VerificationRejecter.new(**auth_info)
    result = conn.call_action(id: params[:id])
    handle_response(result); return if performed?

    flash.notice = @message
    redirect_to api_user_path(params[:id])
  end

  private

  def api_user_params
    params.require(:api_user).permit(:username, :password,
                                     :subject, :country_code, :identity_number,
                                     :email, :roles, :active, :id)
  end

  def format_csv
    raw_csv = ApiUserListCsvPresenter.new(objects: @api_users,
                                          view: view_context).to_s
    send_data raw_csv, filename: "#{filename}.csv", type: "#{Mime[:csv]}; charset=utf-8"
  end

  def filename
    "api_users_#{l(Time.zone.now, format: :filename)}"
  end

  def api_user_payload
    subject = composed_subject

    {
      id: api_user_params[:id],
      username: api_user_params[:username],
      plain_text_password: api_user_params[:password],
      subject: subject,
      country_code: api_user_params[:country_code],
      email: api_user_params[:email],
      roles: [api_user_params[:roles]],
      active: api_user_params[:active] == 'true',
    }
  end

  def composed_subject
    # Keep backward compatibility with old single subject input.
    return api_user_params[:subject] if api_user_params[:subject].present?

    country_code = api_user_params[:country_code].to_s.upcase.strip
    identity_number = api_user_params[:identity_number].to_s.strip
    return '' if country_code.blank? || identity_number.blank?

    "#{country_code}#{identity_number}"
  end

  def changed_own_password?
    return false unless updating_self?

    submitted = api_user_params[:password].to_s
    return false if submitted.blank?

    submitted != current_password_from_token
  end

  def updating_self?
    if current_user_id.present? && api_user_params[:id].present?
      api_user_params[:id].to_s == current_user_id.to_s
    else
      api_user_params[:username] == current_user&.username
    end
  end

  def current_user_id
    auth_info&.dig(:id)
  end

  def current_password_from_token
    return nil if current_user&.token.blank?

    Base64.urlsafe_decode64(current_user.token).split(':', 2).last
  rescue ArgumentError
    nil
  end

end
