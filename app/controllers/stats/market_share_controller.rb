module Stats
  class MarketShareController < BaseController
    before_action :set_default_search_params

    def index
      @type = params[:type]
    end

    def distribution_data
      conn = ApiConnector::Stats::MarketShareDistribution.new(**auth_info)
      result = conn.call_action(q: search_params)
      handle_response(result); return if performed?

      render json: [{ name: t('stats.market_share.index.domains'), colorByPoint: true, data: @response }]
    end

    def growth_rate_data
      conn = ApiConnector::Stats::MarketShareGrowthRate.new(**auth_info)
      result = conn.call_action(q: search_params)
      handle_response(result); return if performed?

      render json: { current: @response.data, previous: @response.prev_data }
    end

    private

    def set_default_search_params
      @search_params = params[:search]&.to_unsafe_h || {}
      today = Time.zone.today
      end_date = @search_params[:end_date].presence || format_date(today)
      last_month = Date.strptime(end_date, '%m.%y').last_month
      compare_to_date = @search_params[:compare_to_date].presence || format_date(last_month)
      @search_params[:end_date] = end_date
      @search_params[:compare_to_date] = compare_to_date
    end

    def format_date(date)
      date.strftime('%m.%y')
    end
  end
end
