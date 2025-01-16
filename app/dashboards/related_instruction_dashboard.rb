require "administrate/base_dashboard"

class RelatedInstructionDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    code: Field::String,
    description: Field::String,
    hours: Field::Number,
    occupation_standard: Field::BelongsTo,
    organization: Field::BelongsTo,
    sort_order: Field::Number,
    title: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    sort_order
    title
    hours
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    code
    description
    hours
    occupation_standard
    organization
    sort_order
    title
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    title
    description
    code
    hours
    sort_order
    organization
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(related_instruction)
    related_instruction.title
  end
end
