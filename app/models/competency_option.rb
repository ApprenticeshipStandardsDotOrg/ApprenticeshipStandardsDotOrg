class CompetencyOption < ApplicationRecord
  belongs_to :resource, polymorphic: true

  validates :sort_order, uniqueness: {scope: :resource_id}
end
