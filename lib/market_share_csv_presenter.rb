require 'csv'
class MarketShareCsvPresenter
  def initialize(data:, type:, params:, view:)
    @data = data
    @type = type
    @params = params
    @view = view
  end

  def to_s
    table = CSV::Table.new([header])

    transformed_data.each do |rar|
      table << rar_data_to_row(rar: OpenStruct.new(rar))
    end

    table.to_s
  end

  attr_reader :data, :type, :params, :view

  private

  # rubocop:disable Metrics/MethodLength
  def header
    period = column_period(params[:start_date], params[:end_date])
    compare_period = column_period(params[:compare_to_start_date], params[:compare_to_end_date])
    case type
    when 'distribution'
      columns = [translate_column('registrar'),
                 "#{translate_column('domains')} [#{period}]"]
    when 'growth_rate'
      columns = [translate_column('registrar'),
                 "#{translate_column('domains')} [#{compare_period}]",
                 "#{translate_column('market_share')} [#{compare_period}]",
                 "#{translate_column('domains')} [#{period}]",
                 "#{translate_column('market_share')} [#{period}]",
                 translate_column('market_share_diff').to_s,
                 translate_column('domains_diff').to_s]
    end

    CSV::Row.new(columns, [], true)
  end
  # rubocop:enable Metrics/MethodLength

  def transformed_data
    case type
    when 'distribution'
      data
    when 'growth_rate'
      transform_growth_rate_data(data)
    end
  end

  def column_period(start_date, end_date, period: '')
    period += "#{translate_date(start_date)} - " if start_date.present?
    period += translate_date(end_date).to_s
    period
  end

  def rar_data_to_row(rar:)
    row = []
    row[0] = rar.name
    if rar.y.is_a? Array
      rar.y.each_with_index do |yy, i|
        row[i + 1] = yy
      end
    else
      row[1] = rar.y
    end

    CSV::Row.new([], row)
  end

  def translate_column(column)
    view.t("stats.market_share.index.csv.#{column}")
  end

  def translate_date(date_param)
    I18n.l(Date.strptime(date_param, '%m.%y'), format: :month_year_short)
  end

  def transform_growth_rate_data(data, hash: {})
    arr = []
    arr.concat(data.prev_data['domains'].concat(data.prev_data['market_share']))
    arr.concat(data.data['domains'].concat(data.data['market_share']))
    arr.each do |e|
      hash[e[0]] = hash[e[0]].presence || []
      hash[e[0]] << e[1]
    end
    hash.to_a.map { |aa| { name: aa[0], y: with_difference(aa[1]) } }.sort_by { |hsh| -hsh[:y][3] }
  end

  def with_difference(values)
    values << (values[3] - values[1]).round(1)
    values << values[2] - values[0]
    values
  end
end
