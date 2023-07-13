class ApplicationController < ActionController::Base # rubocop:disable Metrics/ClassLength
  include Pagy::Backend

  helper_method :current_user, :logged_in?, :can?
  before_action :set_locale

  def current_user
    @current_user ||= OpenStruct.new(auth_info) if auth_info
  end

  def can?(action, subject)
    return false if current_user.abilities[:can].blank?
    return false if current_user.abilities[:can][action].blank?

    current_user.abilities[:can][action].keys.include? subject
  end

  def authorize!(action, subject)
    return if can? action, subject

    respond_to do |format|
      format.html { redirect_to dashboard_url, alert: 'Authorization error' }
    end
  end

  def logged_in?
    current_user != nil
  end

  def sign_out
    session[:uuid] = nil
    Rails.cache.instance_variable_get(:@data)&.each_key do |key|
      Rails.cache.delete(key) unless key.match?(/distribution_data|growth_rate_data/)
    end
  end

  def sign_in(uuid)
    session[:uuid] = uuid
    cookies.delete(:request_ip)
  end

  def reset_bulk_change_cache
    @attrs&.slice!(:type, :form_steps)
    Rails.cache.delete session.id
  end

  def save_bulk_change_cache
    Rails.cache.write session.id, @attrs.except(:batch_file), expires_in: 2.hours
  end

  def handle_response(res, dialog: false)
    if res.success
      handle_successful_response(res)
    else
      handle_error_response(res, dialog: dialog)
    end
  end

  def internal_server_error
    render file: 'public/500.html', layout: false,
           status: :internal_server_error
  end

  def respond_with_log_out(msg)
    sign_out
    respond_to do |format|
      format.html { redirect_to login_url, alert: msg }
    end
  end

  def respond(msg, dialog: false)
    respond_to do |format|
      format.html { respond_html(msg) }
      format.turbo_stream { respond_turbo_stream(msg, dialog) }
    end
  end

  def store_auth_info(token:, data:)
    uuid = SecureRandom.uuid
    Rails.cache.write(uuid, { username: data[:username],
                              registrar_name: data[:registrar_name],
                              role: data[:roles].first,
                              legaldoc_mandatory: data[:legaldoc_mandatory],
                              address_processing: data[:address_processing],
                              token: token,
                              abilities: data[:abilities] }, expires_in: 18.hours)
    uuid
  end

  private

  def handle_successful_response(res)
    msg = res.body[:message]
    unstructable = res[:type].match?(/pdf|octet-stream/) || res.body[:data].is_a?(Array)
    @response = unstructable ? res.body[:data] : OpenStruct.new(res.body[:data])
    @message = msg
  end

  def handle_error_response(res, dialog: false)
    msg = res.body[:message]

    case res.body[:code]
    when 2202, 503, 401
      respond_with_log_out(msg)
    when 2000..2500
      respond(msg, dialog: dialog)
    else
      handle_unexpected_error(msg, dialog: dialog)
    end

    logger.info msg
  end

  def handle_unexpected_error(msg, dialog: false)
    if msg.present?
      respond(msg, dialog: dialog)
    else
      internal_server_error
    end
  end

  def respond_html(msg)
    flash[:alert] = msg
    redirect_back_or_to "/#{I18n.locale}"
  end

  def respond_turbo_stream(msg, dialog)
    flash.now[:alert] = msg

    turbo_stream_render = if dialog
      turbo_stream.update_all('.dialog_flash', partial: 'common/dialog_flash')
    else
      turbo_stream.update('flash', partial: 'common/flash')
    end

    render turbo_stream: turbo_stream_render
  end

  def auth_info
    Rails.cache.fetch(session[:uuid])&.symbolize_keys
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def set_locale
    I18n.locale = extract_locale || I18n.default_locale
    @pagy_locale = I18n.locale.to_s
  end

  def extract_locale
    set_locale_cookie_if_present
    locale = cookies[:locale]

    return locale.to_sym if valid_locale?(locale)

    log_invalid_locale(locale)
    nil
  end

  def set_locale_cookie_if_present
    cookies.permanent[:locale] = params[:locale] if params[:locale].present?
  end

  def valid_locale?(locale)
    I18n.available_locales.map(&:to_s).include?(locale)
  end

  def log_invalid_locale(locale)
    notice = "#{locale} #{t(:no_translation)}"
    # flash.now[:notice] = notice
    logger.error notice
  end
end
