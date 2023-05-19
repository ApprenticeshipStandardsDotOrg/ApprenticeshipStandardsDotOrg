require "administrate/base_dashboard"

class ContactRequestDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    email: Field::String,
    message: Field::Text,
    name: Field::String,
    organization: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    name
    organization
    email
    message
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    email
    message
    name
    organization
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    email
    message
    name
    organization
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
