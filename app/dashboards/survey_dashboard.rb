require "administrate/base_dashboard"

class SurveyDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    name: Field::String,
    email: Field::String,
    organization: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    name
    email
    organization
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    name
    email
    organization
  ].freeze

  FORM_ATTRIBUTES = %i[
    name
    email
    organization
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
