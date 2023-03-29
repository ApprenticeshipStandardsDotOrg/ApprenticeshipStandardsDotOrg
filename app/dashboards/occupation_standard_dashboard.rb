require "administrate/base_dashboard"

class OccupationStandardDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    apprenticeship_to_journeyworker_ratio: Field::String,
    data_imports: Field::HasMany,
    existing_title: Field::String,
    occupation: Field::BelongsTo,
    occupation_type: EnumField,
    ojt_hours_max: Field::Number,
    ojt_hours_min: Field::Number,
    onet_code: Field::String,
    organization: Field::BelongsTo,
    probationary_period_months: Field::Number,
    rapids_code: Field::String,
    registration_agency: Field::BelongsTo,
    related_instructions: Field::HasMany,
    rsi_hours_max: Field::Number,
    rsi_hours_min: Field::Number,
    status: EnumField,
    term_months: Field::Number,
    title: Field::String,
    url: Field::String,
    wage_steps: Field::HasMany,
    work_processes: Field::HasMany,
    source_file: Field::String,
    created_at: Field::DateTime.with_options(format: :short),
    updated_at: Field::DateTime.with_options(format: :short)
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    title
    occupation
    registration_agency
    onet_code
    status
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    status
    occupation
    url
    registration_agency
    rapids_code
    onet_code
    created_at
    updated_at

    data_imports

    work_processes
    related_instructions
    wage_steps
  ].freeze

  FORM_ATTRIBUTES = %i[
    title
    onet_code
    rapids_code
    status
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(occupation_standard)
    "Occupation Standard for #{occupation_standard.title}"
  end
end
