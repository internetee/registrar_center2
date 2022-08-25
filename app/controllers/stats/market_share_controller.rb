module Stats
  class MarketShareController < BaseController
    def index; end

    def domains_by_registrar
      conn = ApiConnector::Stats::MarketShare.new(**auth_info)
      result = conn.call_action(q: search_params)

      render json: [{ name: 'Domains', colorByPoint: true, data: result.body[:data] }]
    end
  end
end
