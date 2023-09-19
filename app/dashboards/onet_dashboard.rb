require "administrate/base_dashboard"

class OnetDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    code: Field::String,
    name: Field::String,
    related_job_titles: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    code
    name
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    code
    name
    related_job_titles
    created_at
    updated_at
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(onet)
    onet.code
  end
end
