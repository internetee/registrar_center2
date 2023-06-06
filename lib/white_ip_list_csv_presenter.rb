class WhiteIpListCsvPresenter < CsvPresenter
  def to_s
    table = CSV::Table.new([header])

    objects.each do |ip|
      table << ip_to_row(ip: OpenStruct.new(ip))
    end

    table.to_s
  end

  private

  def header
    columns = %w[
      ipv4
      ipv6
      interfaces
      created_at
      updated_at
    ]

    columns.map! { |column| view.t("white_ips.index.csv.#{column}") }

    CSV::Row.new(columns, [], true)
  end

  def ip_to_row(ip:)
    row = []
    row[0] = ip.ipv4
    row[1] = ip.ipv6
    row[2] = ip.interfaces
    row[3] = view.l(ip.created_at.to_datetime)
    row[4] = view.l(ip.updated_at.to_datetime)

    CSV::Row.new([], row)
  end
end
