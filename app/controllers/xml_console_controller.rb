class XmlConsoleController < BaseController
  def show; end

  def create
    conn = ApiConnector::XmlConsole::Creator.new(**auth_info)
    result = conn.call_action(payload: params[:payload])
    handle_response(result); return if performed?

    respond_to do |format|
      format.html { render :show }
      format.turbo_stream
    end
  end

  def load
    conn = ApiConnector::XmlConsole::Loader.new(**auth_info)
    result = conn.call_action(obj: params[:obj], epp_action: params[:epp_action])
    handle_response(result); return if performed?

    render xml: @response.xml
  end
end
