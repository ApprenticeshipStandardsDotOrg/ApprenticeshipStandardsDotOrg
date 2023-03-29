require "administrate/base_dashboard"

class SourceFileDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    active_storage_attachment: Field::BelongsTo,
    data_imports: HasManyDataImportsField,
    url: Field::Url,
    metadata: Field::JSONB,
    status: EnumField,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    created_at
    active_storage_attachment
    status
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    data_imports
  ].freeze

  FORM_ATTRIBUTES = %i[
    metadata
    status
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(source_file)
    source_file.active_storage_attachment.filename
  end
end
