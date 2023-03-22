require "administrate/base_dashboard"

class OccupationStandardDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
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

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    title
    occupation
    registration_agency
    onet_code
    status
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    status
    occupation
    url
    registration_agency
    rapids_code
    onet_code
    created_at
    updated_at

    source_file
    data_imports

    work_processes
    related_instructions
    wage_steps
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    title
    onet_code
    rapids_code
    status

    work_processes
    related_instructions
    wage_steps
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
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how occupation standards are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(occupation_standard)
    "Occupation Standard for #{occupation_standard.title}"
  end
end
