class OccupationStandardSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :display, :link

  def link
    occupation_standard_path(object)
  end

  def display
    object.display_for_typeahead
  end
end
