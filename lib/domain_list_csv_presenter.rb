require 'csv'
class DomainListCsvPresenter
  def initialize(domains:, view:)
    @domains = domains
    @view = view
  end

  def to_s
    table = CSV::Table.new([header])

    domains.each do |domain|
      table << domain_to_row(domain: OpenStruct.new(domain))
    end

    table.to_s
  end

  private

  def header
    columns = %w[
      domain_name
      transfer_code
      registrant_name
      registrant_code
      expire_time
    ]

    columns.map! { |column| view.t("domains.index.csv.#{column}") }

    CSV::Row.new(columns, [], true)
  end

  def domain_to_row(domain:)
    row = []
    row[0] = domain.name
    row[1] = domain.transfer_code
    row[2] = domain.registrant[:name]
    row[3] = domain.registrant[:code]
    row[4] = view.l(domain.expire_time.to_datetime, format: :date)

    CSV::Row.new([], row)
  end

  attr_reader :domains, :view
end
