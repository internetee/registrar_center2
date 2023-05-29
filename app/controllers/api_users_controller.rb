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
    handle_response(result); return if performed?

    flash.notice = @message
    redirect_to api_user_path(@response.api_user[:id])
  end

  def update
    conn = ApiConnector::ApiUsers::Updater.new(**auth_info)
    result = conn.call_action(payload: api_user_payload)
    handle_response(result); return if performed?

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

  private

  def api_user_params
    params.require(:api_user).permit(:username, :password,
                                     :identity_code, :role, :active, :id)
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
    {
      id: api_user_params[:id],
      username: api_user_params[:username],
      plain_text_password: api_user_params[:password],
      identity_code: api_user_params[:identity_code],
      roles: [api_user_params[:role]],
      active: api_user_params[:active] == 'true',
    }
  end
end
