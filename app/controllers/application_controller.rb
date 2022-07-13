class ApplicationController < ActionController::Base
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

  def logged_in?
    current_user != nil
  end

  def sign_out
    session[:uuid] = nil
    Rails.cache.clear
  end

  def sign_in(uuid)
    session[:uuid] = uuid
  end

  def reset_bulk_change_cache
    @attrs&.slice!(:type, :form_steps)
    Rails.cache.delete session.id
  end

  def save_bulk_change_cache
    Rails.cache.write session.id, @attrs.except(:batch_file), expires_in: 2.hours
  end

  # rubocop:disable Metrics/MethodLength
  def handle_response(res)
    msg = res.body[:message]
    if res.success
      pdf = (res[:type] == 'application/pdf')
      @response = pdf ? res.body[:data] : OpenStruct.new(res.body[:data])
      @message = msg
    else
      case res.body[:code]
      when 2202, 503, 401
        respond_with_log_out(msg)
      when 2000..2500
        respond(msg)
      else
        msg.present? ? respond(msg) : internal_server_error
      end
      logger.info msg
    end
  end
  # rubocop:enable Metrics/MethodLength

  def internal_server_error
    render file: 'public/500.html',
           layout: false,
           status: :internal_server_error
  end

  def respond_with_log_out(msg)
    sign_out
    respond_to do |format|
      format.html { redirect_to login_url, alert: msg }
    end
  end

  def respond(msg)
    respond_to do |format|
      format.html do
        flash[:alert] = msg
        redirect_back_or_to "/#{I18n.locale}"
      end
      format.turbo_stream do
        flash.now[:alert] = msg
        render turbo_stream: turbo_stream.update('flash', partial: 'common/flash')
      end
    end
  end

  def store_auth_info(token:, data:)
    uuid = SecureRandom.uuid
    Rails.cache.write(uuid, { username: data[:username],
                              registrar_name: data[:registrar_name],
                              role: data[:roles].first,
                              legaldoc_mandatory: data[:legaldoc_mandatory],
                              token: token,
                              abilities: data[:abilities] }, expires_in: 18.hours)
    uuid
  end

  private

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
    locale = params[:locale]
    return locale.to_sym if I18n.available_locales.map(&:to_s).include?(locale)

    # notice = "#{locale} #{t(:no_translation)}"
    # flash.now[:notice] = notice
    logger.error notice
    nil
  end
end
