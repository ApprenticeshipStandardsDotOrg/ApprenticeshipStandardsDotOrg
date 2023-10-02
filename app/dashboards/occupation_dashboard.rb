require "administrate/base_dashboard"

class OccupationDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    title: Field::String,
    description: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    rapids_code: Field::String,
    time_based_hours: Field::Number,
    competency_based_hours: Field::Number,
    onet: Field::BelongsTo,
    hybrid_hours_max: Field::Number,
    hybrid_hours_min: Field::Number
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    title
    description
    onet
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    title
    description
    rapids_code
    time_based_hours
    competency_based_hours
    onet
    hybrid_hours_max
    hybrid_hours_min
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    title
    description
    time_based_hours
    competency_based_hours
    hybrid_hours_max
    hybrid_hours_min
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(occupation)
    occupation.to_s
  end
end
