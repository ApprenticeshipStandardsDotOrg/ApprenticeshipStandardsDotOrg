class OccupationStandardBlueprint < Blueprinter::Base
  identifier :id

  field :display_for_typeahead, name: :display

  field :link do |resource, options|
    Rails.application.routes.url_helpers.occupation_standards_path
  end
end
