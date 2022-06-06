class AccountController < BaseController
  before_action :set_pagy_params, only: :index

  def index
    conn = ApiConnector::Account::AllActivities.new(**auth_info)
    result = conn.call_action(q: search_params,
                              limit: pdf_or_csv_request? ? nil : session[:page_size],
                              offset: pdf_or_csv_request? ? nil : @offset)
    handle_response(result); return if performed?

    @activities = @response.activities
    @activity_types = @response.types_for_select
    @pagy = Pagy.new(count: @response.count, items: session[:page_size], page: @page)
    respond_to do |format|
      format.html
      format.csv { format_csv }
    end
  end

  def show
    result = ApiConnector::Account::Reader.call(**auth_info)
    handle_response(result); return if performed?

    @account = @response.account
    @balance_auto_reload = @response.account[:balance_auto_reload]
    @min_deposit = @response.account[:min_deposit]
  end

  def update
    conn = ApiConnector::Account::Updater.new(**auth_info)
    result = conn.call_action(payload: account_payload)
    handle_response(result); return if performed?

    flash.notice = @message
    redirect_to account_path
  end

  def update_balance_auto_reload
    conn = ApiConnector::Account::BalanceAutoReloadUpdater.new(**auth_info)
    result = conn.call_action(payload: auto_reload_payload)
    handle_response(result); return if performed?

    flash.notice = @message
    redirect_to account_path
  end

  def disable_balance_auto_reload
    result = ApiConnector::Account::BalanceAutoReloadDeleter.call(**auth_info)
    handle_response(result); return if performed?

    flash.notice = @message
    redirect_to account_path
  end

  private

  def account_params
    params.require(:account).permit(:billing_email, :iban,
                                    :auto_reload_amount,
                                    :auto_reload_threshold, :user_id)
  end

  def account_payload
    {
      billing_email: account_params[:billing_email],
      iban: account_params[:iban],
    }
  end

  def auto_reload_payload
    {
      amount: account_params[:auto_reload_amount],
      threshold: account_params[:auto_reload_threshold],
    }
  end

  def format_csv
    raw_csv = ActivityListCsvPresenter.new(activities: @activities,
                                           view: view_context).to_s
    filename = "account_activities_#{Time.zone.now.to_formatted_s(:number)}.csv"
    send_data raw_csv, filename: filename, type: "#{Mime[:csv]}; charset=utf-8"
  end
end