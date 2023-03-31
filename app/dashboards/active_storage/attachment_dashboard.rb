require "administrate/base_dashboard"

module ActiveStorage
  class AttachmentDashboard < Administrate::BaseDashboard
    ATTRIBUTE_TYPES = {
      id: Field::Number,
      name: Field::String,
      record: Field::Polymorphic,
      blob: Field::BelongsTo,
      created_at: Field::DateTime
    }.freeze

    COLLECTION_ATTRIBUTES = [
      :id,
      :name,
      :record,
      :blob,
      :created_at
    ].freeze

    SHOW_PAGE_ATTRIBUTES = [
      :id,
      :name,
      :record,
      :blob,
      :created_at
    ].freeze

    FORM_ATTRIBUTES = [
      :name
    ].freeze

    def display_resource(attachment)
      attachment.filename
    end
  end
end
