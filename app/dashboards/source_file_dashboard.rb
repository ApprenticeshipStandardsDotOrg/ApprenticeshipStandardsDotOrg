require "administrate/base_dashboard"

class SourceFileDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    active_storage_attachment: Field::BelongsTo,
    data_imports: HasManyDataImportsField,
    metadata: Field::JSONB,
    notes: Field::String.with_options(searchable: false),
    organization: Field::String.with_options(searchable: false),
    status: EnumField.with_options(searchable: false),
    courtesy_notification: EnumField.with_options(searchable: false),
    url: Field::Url.with_options(searchable: false),
    assignee: AssigneeField,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    public_document: Field::Boolean,
    redacted_source_file: Field::ActiveStorage.with_options(
      destroy_url: proc do |namespace, resource, attachment|
        [:redacted_source_file_admin_source_file, {attachment_id: attachment.id}]
      end
    ),
    redacted_source_file_url: Field::Url.with_options(searchable: false),
    associated_occupation_standards: HasManyAssociatedOccupationStandardsField,
    original_source_file: Field::BelongsTo,
    standards_import: GenericRecordField,
    plain_text_version: Field::Text

  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    created_at
    organization
    active_storage_attachment
    status
    assignee
    public_document
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    status
    courtesy_notification
    data_imports
    metadata
    organization
    active_storage_attachment
    url
    notes
    assignee
    public_document
    redacted_source_file
    redacted_source_file_url
    original_source_file
    associated_occupation_standards
    standards_import
    plain_text_version
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    metadata
    status
    assignee
    public_document
    courtesy_notification
    redacted_source_file
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(source_file)
    source_file.active_storage_attachment.filename
  end
end
