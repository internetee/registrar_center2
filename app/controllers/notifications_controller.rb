class NotificationsController < BaseController
  # Mark message as read
  def mark_as_read
    conn = ApiConnector::NotificationReadMarker.new(**auth_info)
    result = conn.call_action(id: params[:id].to_i)
    handle_response(result); return if performed?

    flash.notice = @message
    redirect_to dashboard_path
  end
end
