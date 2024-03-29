class CompetencyOption < ApplicationRecord
  belongs_to :resource, polymorphic: true, counter_cache: true

  validates :sort_order, uniqueness: {scope: :resource_id}
  validates :title, :sort_order, presence: true
end
