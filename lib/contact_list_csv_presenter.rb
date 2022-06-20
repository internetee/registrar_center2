require 'csv'
class ContactListCsvPresenter
  def initialize(contacts:, view:)
    @contacts = contacts
    @view = view
  end

  def to_s
    table = CSV::Table.new([header])

    contacts.each do |contact|
      table << contact_to_row(contact: OpenStruct.new(contact))
    end

    table.to_s
  end

  private

  def header
    columns = %w[
      name
      id
      ident
      email
      created_at
      phone
    ]

    columns.map! { |column| view.t("contacts.index.csv.#{column}") }

    CSV::Row.new(columns, [], true)
  end

  def contact_to_row(contact:)
    row = []
    row[0] = contact.name
    row[1] = contact.code
    row[2] = view.ident_for(contact)
    row[3] = contact.email
    row[4] = view.l(contact.created_at.to_datetime)
    row[5] = contact.phone

    CSV::Row.new([], row)
  end

  attr_reader :contacts, :view
end
