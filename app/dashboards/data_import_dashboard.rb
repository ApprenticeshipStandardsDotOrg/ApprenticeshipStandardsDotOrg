require "administrate/base_dashboard"

class DataImportDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    description: Field::String,
    file: Field::ActiveStorage,
    filename: Field::String,
    occupation_standard: Field::BelongsTo,
    occupation_standard_title: Field::String,
    import: Field::BelongsTo.with_options(class_name: "Import"),
    status: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    filename
    status
    occupation_standard
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    description
    file
    import
    occupation_standard
    status
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    description
    file
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(data_import)
    data_import.file.filename.to_s.truncate(50)
  end
end
