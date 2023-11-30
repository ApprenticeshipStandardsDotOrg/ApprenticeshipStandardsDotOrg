require "administrate/base_dashboard"

class StandardsImportDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    email: Field::String,
    files: Field::ActiveStorage,
    name: Field::String,
    notes: Field::Text,
    organization: Field::String,
    courtesy_notification: EnumField.with_options(searchable: false),
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    name
    organization
    courtesy_notification
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    email
    files
    name
    notes
    organization
    courtesy_notification
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    name
    email
    organization
    notes
    courtesy_notification
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def permitted_attributes
    super + [attachments: []]
  end
end
