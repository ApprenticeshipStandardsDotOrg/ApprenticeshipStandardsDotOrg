require "administrate/base_dashboard"

class OrganizationDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    courses: Field::HasMany,
    logo_attachment: Field::ActiveStorage,
    logo_blob: Field::HasOne,
    occupation_standards: Field::HasMany,
    organization_type: Field::String,
    title: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    title
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    logo_attachment
    logo_blob
    occupation_standards
    organization_type
    title
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    occupation_standards
    organization_type
    title
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(organization)
    organization.title
  end
end
