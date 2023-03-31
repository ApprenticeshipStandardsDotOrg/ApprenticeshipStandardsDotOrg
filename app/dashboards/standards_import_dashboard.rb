require "administrate/base_dashboard"

class StandardsImportDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    email: Field::String,
    files: Field::ActiveStorage,
    name: Field::String,
    notes: Field::Text,
    organization: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    email
    files
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    email
    files
    name
    notes
    organization
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    name
    email
    organization
    notes
    files
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def permitted_attributes
    super + [attachments: []]
  end
end
