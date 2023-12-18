module StatsHelper
  def market_share_distribution_chart(search_params)
    url = market_share_distribution_data_path(search: search_params)
    title = t('stats.market_share.distribution.chart_title',
              date: title_period(search_params[:start_date],
                                 search_params[:end_date]))
    tag.div(nil, data: chart_data_params(url: url, title: title, type: __method__.to_s)) do
      tag.div(preloader, class: 'pie_chart')
    end
  end

  # rubocop:disable Metrics/MethodLength
  def market_share_growth_rate_chart(search_params)
    url = market_share_growth_rate_data_path(search: search_params)
    title = t('stats.market_share.growth_rate.chart_title',
              date: title_period(search_params[:start_date],
                                 search_params[:end_date]))
    subtitle = t('stats.market_share.growth_rate.chart_subtitle',
                 date: title_period(search_params[:compare_to_start_date],
                                    search_params[:compare_to_end_date]))
    tag.div(nil, data: chart_data_params(url: url, title: title, type: __method__.to_s,
                                         subtitle: subtitle,
                                         translations: date_translations(search_params))) do
      data_type_radio_buttons + tag.div(preloader, class: 'bar_chart')
    end
  end
  # rubocop:enable Metrics/MethodLength

  private

  def preloader
    tag.div(nil, class: 'fulfilling-bouncing-circle-spinner') do
      tag.div(nil, class: 'circle') + tag.div(nil, class: 'orbit')
    end
  end

  def data_type_radio_buttons(tags: [])
    tag.form do
      t('stats.market_share.index.chart_text.yAxisTitle').each do |key, value|
        tags << radio_button_tag('select[data_type]', key, key == :market_share,
                                 'data-action': 'chart#toggleChartDataType',
                                 class: 'form--radio')
        tags << label_tag("select_data_type_#{key}", value, value: key, class: 'form--radiolabel')
      end
      safe_join(tags, "\n")
    end
  end

  def title_period(start_date, end_date, period: '')
    period += "#{translate_date(to_date(start_date))} - " if start_date.present?
    period += translate_date(to_date(end_date, end_date: true)).to_s

    period
  end

  def to_date(month_year, end_date: false)
    parsed_date = Date.strptime(month_year, '%m.%y')
    return parsed_date unless end_date

    current_date = Time.zone.today

    if parsed_date.month == current_date.month && parsed_date.year == current_date.year
      current_date
    else
      parsed_date.end_of_month
    end
  end

  def translate_date(date)
    I18n.l(date, format: :month_year)
  end

  def chart_data_params(url:, title:, type:, subtitle: nil, translations: {})
    {
      'controller': 'chart',
      'chart-url-value': url,
      'chart-title-value': title,
      'chart-type-value': type,
      'chart-subtitle-value': subtitle,
      'chart-translations-value': t('.chart_text').merge(translations),
    }
  end

  def date_translations(params, dates: {})
    end_date = to_date(params[:end_date], end_date: true)
    compare_to_end_date = to_date(params[:compare_to_end_date], end_date: true)
    dates[params[:end_date]] = translate_date(end_date)
    dates[params[:compare_to_end_date]] = translate_date(compare_to_end_date)

    dates
  end
end
