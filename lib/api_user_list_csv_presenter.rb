class ApiUserListCsvPresenter < CsvPresenter
  def to_s
    table = CSV::Table.new([header])

    objects.each do |user|
      table << user_to_row(user: OpenStruct.new(user))
    end

    table.to_s
  end

  private

  def header
    columns = %w[
      username
      password
      identity_code
      role
      active
      accredited
      accreditation_expire_date
      created_at
      updated_at
    ]

    columns.map! { |column| view.t("api_users.index.csv.#{column}") }

    CSV::Row.new(columns, [], true)
  end

  def user_to_row(user:)
    row = []
    row[0] = user.name
    row[1] = user.password
    row[2] = user.identity_code
    row[3] = user.roles
    row[4] = user.active
    row[5] = user.accredited
    row[6] = user.accreditation_expire_date
    row[7] = view.l(user.created_at.to_datetime)
    row[8] = view.l(user.updated_at.to_datetime)

    CSV::Row.new([], row)
  end
end
