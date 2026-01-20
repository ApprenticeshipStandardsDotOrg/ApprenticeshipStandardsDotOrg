require "administrate/base_dashboard"

class AIComparisonResultDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String.with_options(searchable: false),
    occupation_standard: Field::BelongsTo,
    work_processes_score: Field::Number.with_options(decimals: 2),
    related_instructions_score: Field::Number.with_options(decimals: 2),
    overall_score: Field::Number.with_options(decimals: 2),
    needs_review: Field::Boolean,
    flagged_by_system: Field::Boolean,
    flagged_by_user: Field::Boolean,
    work_processes_comparison_details: Field::Text,
    related_instructions_comparison_details: Field::Text,
    notes: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    occupation_standard
    overall_score
    work_processes_score
    related_instructions_score
    needs_review
    flagged_by_system
    flagged_by_user
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    occupation_standard
    overall_score
    work_processes_score
    related_instructions_score
    needs_review
    flagged_by_system
    flagged_by_user
    work_processes_comparison_details
    related_instructions_comparison_details
    notes
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    occupation_standard
    needs_review
    flagged_by_user
    notes
  ].freeze

  COLLECTION_FILTERS = {
    needs_review: ->(resources, _arg) { resources.needs_review },
    flagged: ->(resources, _arg) { resources.flagged },
    low_score: ->(resources, arg) {
      threshold = (arg.to_f > 0) ? arg.to_f : 70
      resources.low_score(threshold)
    }
  }.freeze

  def display_resource(ai_comparison_result)
    "#{ai_comparison_result.occupation_standard&.title} (Score: #{ai_comparison_result.overall_score || "N/A"})"
  end
end
