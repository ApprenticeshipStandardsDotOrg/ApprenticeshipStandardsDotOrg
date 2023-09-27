class OccupationBlueprint < Blueprinter::Base
  identifier :id

  field :display_for_typeahead, name: :display

  # The link field is the occupation_standards path since that is
  # the path we want to use in the search. Occupations are just
  # used for the initial typeahead search.
  field :link do |resource, options|
    Rails.application.routes.url_helpers.occupation_standards_path
  end
end
