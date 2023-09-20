class OccupationBlueprint < Blueprinter::Base
  identifier :id

  field :display_for_typeahead, name: :display

  field :link do |resource, options|
    Rails.application.routes.url_helpers.occupations_path
  end
end
