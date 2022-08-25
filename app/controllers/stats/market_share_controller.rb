module Stats
  class MarketShareController < BaseController
    def index; end

    def domains_by_registrar
      conn = ApiConnector::Stats::MarketShare.new(**auth_info)
      result = conn.call_action(q: search_params)
      handle_response(result); return if performed?

      render json: [{ name: 'Domains', colorByPoint: true, data: @response }]
    end
  end
end
