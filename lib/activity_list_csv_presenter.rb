require 'csv'
class ActivityListCsvPresenter
  def initialize(activities:, view:)
    @activities = activities
    @view = view
  end

  def to_s
    table = CSV::Table.new([header])

    activities.each do |activity|
      table << activity_to_row(activity: OpenStruct.new(activity))
    end

    table.to_s
  end

  private

  def header
    columns = %w[
      description
      activity_type
      receipt_date
      sum
    ]

    columns.map! { |column| view.t("account.index.csv.#{column}") }

    CSV::Row.new(columns, [], true)
  end

  def activity_to_row(activity:)
    row = []
    row[0] = activity.description
    row[1] = activity.type
    row[2] = view.l(activity.created_at.to_date)
    row[3] = activity.sum

    CSV::Row.new([], row)
  end

  attr_reader :activities, :view
end
