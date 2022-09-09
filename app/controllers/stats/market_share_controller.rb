module Stats
  class MarketShareController < BaseController
    before_action :set_default_search_params

    def index
      @type = params[:type] || 'distribution'
      respond_to do |format|
        format.html
        format.csv do
          params[:search] = @search_params
          method = @type == 'distribution' ? :distribution_data : :growth_rate_data
          send(method)
          format_csv
        end
      end
    end

    def distribution_data
      conn = ApiConnector::Stats::MarketShareDistribution.new(**auth_info)
      result = conn.call_action(q: search_params)
      handle_response(result); return if performed? || request.format.csv?

      render json: [{ name: t('stats.market_share.index.domains'),
                      colorByPoint: true,
                      data: @response }]
    end

    def growth_rate_data
      conn = ApiConnector::Stats::MarketShareGrowthRate.new(**auth_info)
      result = conn.call_action(q: search_params)
      handle_response(result); return if performed? || request.format.csv?

      add_data = []
      40.times do
        add_data << [(0...8).map { (65 + rand(26)).chr }.join, rand(1..100)]
      end
      @response.prev_data['domains'] = @response.prev_data['domains'] + add_data
      @response.prev_data['market_share'] = @response.prev_data['market_share'] + add_data
      @response.data['domains'] = @response.data['domains'] + add_data
      @response.data['market_share'] = @response.data['market_share'] + add_data
      render json: { current: @response.data, previous: @response.prev_data,
                     current_registrar: current_user.registrar_name }
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

    def format_csv
      raw_csv = MarketShareCsvPresenter.new(data: @response,
                                            type: @type,
                                            params: @search_params,
                                            view: view_context).to_s
      send_data raw_csv, type: "#{Mime[:csv]}; charset=utf-8"
    end
  end
end
