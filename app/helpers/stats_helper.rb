module StatsHelper
  def market_share_distribution_chart(search_params)
    url = market_share_distribution_data_path(search: search_params)
    title = t('stats.market_share.distribution.chart_title',
              date: title_period(search_params))
    tag.div(nil, data: chart_data_params(url: url, title: title, type: __method__.to_s),
                 class: 'pie_chart')
  end

  def market_share_growth_rate_chart(search_params)
    url = market_share_growth_rate_data_path(search: search_params)
    title = t('stats.market_share.growth_rate.chart_title',
              date: title_period(search_params))
    subtitle = t('stats.market_share.growth_rate.chart_subtitle',
                 date: translate_date(to_date(search_params[:compare_to_date])))
    tag.div(nil, data: chart_data_params(url: url, title: title, type: __method__.to_s,
                                         subtitle: subtitle,
                                         translations: date_translations(search_params))) do
      data_type_radio_buttons + tag.div(nil, class: 'bar_chart')
    end
  end

  private

  def data_type_radio_buttons(tags: '')
    tag.form do
      t('stats.market_share.index.chart_text.yAxisTitle').each do |key, value|
        tags += radio_button_tag('select[data_type]', key, key == :domains,
                                 'data-action': 'chart#toggleChartDataType',
                                 class: 'form--radio')
        tags += label_tag("select_data_type_#{key}", value, value: key, class: 'form--radiolabel')
      end
      tags.html_safe
    end
  end

  def title_period(params, period: '')
    period += "#{translate_date(to_date(params[:start_date]))} - " if params[:start_date].present?
    period += translate_date(to_date(params[:end_date])).to_s
    period
  end

  def to_date(month_year)
    Date.strptime(month_year, '%m.%y')
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
    end_date = to_date(params[:end_date])
    compare_to_date = to_date(params[:compare_to_date])
    dates[params[:end_date]] = translate_date(end_date)
    dates[params[:compare_to_date]] = translate_date(compare_to_date)
    dates
  end
end
