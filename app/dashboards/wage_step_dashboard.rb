require "administrate/base_dashboard"

class WageStepDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    duration_in_months: Field::Number,
    minimum_hours: Field::Number,
    occupation_standard: Field::BelongsTo,
    ojt_percentage: Field::String.with_options(searchable: false),
    rsi_hours: Field::Number,
    sort_order: Field::Number,
    title: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    sort_order
    title
    minimum_hours
    ojt_percentage
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    duration_in_months
    minimum_hours
    occupation_standard
    ojt_percentage
    rsi_hours
    sort_order
    title
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    duration_in_months
    minimum_hours
    occupation_standard
    ojt_percentage
    rsi_hours
    sort_order
    title
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(wage_step)
    wage_step.title
  end
end
