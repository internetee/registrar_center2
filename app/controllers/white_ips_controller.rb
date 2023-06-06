class WhiteIpsController < BaseController
  def index
    conn = ApiConnector::WhiteIps::All.new(**auth_info)
    result = conn.call_action(limit: nil, offset: nil)
    handle_response(result); return if performed?

    @white_ips = @response.ips
    respond_to do |format|
      format.csv { format_csv }
    end
  end

  def show
    conn = ApiConnector::WhiteIps::Reader.new(**auth_info)
    result = conn.call_action(id: params[:id])
    handle_response(result); return if performed?

    @white_ip = @response.ip
    @interfaces = @response.interfaces
  end

  def create
    conn = ApiConnector::WhiteIps::Creator.new(**auth_info)
    result = conn.call_action(payload: white_ip_payload)
    handle_response(result, dialog: true); return if performed?

    flash.notice = @message
    redirect_to white_ip_path(@response.ip[:id])
  end

  def update
    conn = ApiConnector::WhiteIps::Updater.new(**auth_info)
    result = conn.call_action(payload: white_ip_payload)
    handle_response(result, dialog: true); return if performed?

    flash.notice = @message
    redirect_to white_ip_path(@response.ip[:id])
  end

  def destroy
    conn = ApiConnector::WhiteIps::Deleter.new(**auth_info)
    result = conn.call_action(id: params[:id])
    handle_response(result); return if performed?

    flash.notice = @message
    redirect_to account_path
  end

  private

  def white_ip_params
    params.require(:white_ip).permit(:id, :ipv4, :ipv6, interfaces: [])
  end

  def format_csv
    raw_csv = WhiteIpListCsvPresenter.new(objects: @white_ips,
                                          view: view_context).to_s
    send_data raw_csv, filename: "#{filename}.csv", type: "#{Mime[:csv]}; charset=utf-8"
  end

  def filename
    "white_ips_#{l(Time.zone.now, format: :filename)}"
  end

  def white_ip_payload
    payload = white_ip_params
    payload[:interfaces] = white_ip_params[:interfaces] || []
    payload
  end
end
