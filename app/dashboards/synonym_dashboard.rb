require "administrate/base_dashboard"

class SynonymDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    synonyms: Field::String,
    word: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    word
    synonyms
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    word
    synonyms
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    word
    synonyms
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(synonym)
    "Synonyms for #{synonym.word}"
  end
end
