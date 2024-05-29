require "administrate/base_dashboard"

class ImportDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::String,
    assignee: AssigneeField,
    type: Field::String,
    courtesy_notification: Field::Select.with_options(searchable: false, collection: ->(field) { field.resource.class.send(field.attribute.to_s.pluralize).keys }),
    metadata: Field::JSONB,
    file: Field::ActiveStorage,
    filename: Field::String.with_options(searchable: false),
    parent: Field::Polymorphic,
    import: Field::BelongsTo,
    imports: Field::HasMany,
    processed_at: Field::DateTime,
    processing_errors: Field::Text,
    public_document: Field::Boolean,
    associated_occupation_standards: HasManyAssociatedOccupationStandardsField,
    redacted_pdf: Field::ActiveStorage.with_options(
      destroy_url: proc do |namespace, resource, attachment|
        [:redacted_import_admin_import, {attachment_id: attachment.id}]
      end
    ),
    redacted_pdf_url: Field::Url.with_options(searchable: false),
    status: Field::Select.with_options(searchable: false, collection: ->(field) { field.resource.class.send(field.attribute.to_s.pluralize).keys }),
    data_imports: HasManyDataImportsField,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    created_at
    type
    filename
    assignee
    public_document
    status
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    type
    file
    assignee
    status
    metadata
    public_document
    redacted_pdf
    redacted_pdf_url
    processed_at
    processing_errors
    courtesy_notification
    parent
    import
    imports
    data_imports
    associated_occupation_standards
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    assignee
    metadata
    public_document
    status
    courtesy_notification
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {
    status: ->(resources, arg) { resources.where(status: arg) },
    assignee: ->(resources, arg) {
      resources.joins(:assignee).where("users.name ILIKE ?", "%#{arg}%")
    },
    organization: ->(resources, arg) {
      resources
        .joins("JOIN standards_imports ON (standards_imports.id = imports.parent_id AND imports.parent_type = 'StandardsImport')")
        .where("standards_imports.organization ILIKE ?", "%#{arg}%")
    },
    public_document: ->(resources, arg) { resources.where(public_document: arg) },
    file: ->(resources, arg) {
      resources
        .joins("JOIN active_storage_attachments ON (active_storage_attachments.record_id = imports.id)")
        .joins("JOIN active_storage_blobs ON (active_storage_attachments.blob_id = active_storage_blobs.id)")
        .where("active_storage_blobs.filename ILIKE ?", "%#{arg}%")
    },
    needs_redaction: ->(resources) { resources.ready_for_redaction },
    redacted: ->(resources) { resources.already_redacted }
  }.freeze

  # Overwrite this method to customize how imports are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(import)
    import.filename
  end
end
