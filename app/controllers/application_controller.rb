class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Authentication
  include Authorization
  include Localization

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
end
