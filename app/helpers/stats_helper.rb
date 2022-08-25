module StatsHelper
  def domains_by_registrar_chart(search_params)
    url = domains_by_registrar_stats_market_share_index_path(search: search_params)
    title = t('stats.market_share.domains_by_registrar.chart_title',
              date: title_date(search_params))
    content_tag(:div, nil, data: { 'controller': 'chart',
                                   'chart-url-value': url,
                                   'chart-title-value': title,
                                   'chart-translations-value': t('.chart_text') },
                           class: 'pie_chart')
  end

  private

  def title_date(params)
    return I18n.l(Date.today, format: :month_year).to_s unless params

    period = ''
    if params[:start_date].present?
      start_date = Date.strptime(params[:start_date], '%m.%y')
      period += "#{I18n.l(start_date, format: :month_year)} - "
    end
    end_date = params[:end_date].present? ? Date.strptime(params[:end_date], '%m.%y') : Date.today
    period += I18n.l(end_date, format: :month_year).to_s
    period
  end
end
