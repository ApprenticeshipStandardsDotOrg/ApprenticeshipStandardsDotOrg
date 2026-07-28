require "administrate/base_dashboard"

class StandardsImportDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    email: Field::String,
    name: Field::String,
    notes: Field::Text,
    organization: Field::String,
    files: PseudoFileUploadField,
    imports: Field::HasMany,
    has_imports: Field::Boolean.with_options(searchable: false),
    courtesy_notification: EnumField.with_options(searchable: false),
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    created_at
    name
    organization
    has_imports
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    email
    name
    notes
    organization
    courtesy_notification
    imports
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    name
    email
    organization
    notes
    files
    courtesy_notification
  ].freeze

  COLLECTION_FILTERS = {
    has_imports: ->(resources, arg) {
      if ActiveModel::Type::Boolean.new.cast(arg)
        resources.with_imports
      else
        resources.without_imports
      end
    }
  }.freeze

  def permitted_attributes(action = nil)
    super + [files: []]
  end
end
