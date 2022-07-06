require 'csv'
class CsvPresenter
  def initialize(objects:, view:)
    @objects = objects
    @view = view
  end

  def to_s; end

  attr_reader :objects, :view
end