class Industry < ApplicationRecord
  CURRENT_VERSION = "2018"
  POPULAR_LIMIT = 4

  has_many :occupation_standards

  validates :name, :version, presence: true
  validates :prefix, presence: true, uniqueness: {scope: :version}

  scope :current, -> { where(version: CURRENT_VERSION) }

  def self.popular(limit: POPULAR_LIMIT)
    Industry.joins(occupation_standards: :work_processes)
      .group("industries.id")
      .order(Arel.sql("COUNT(DISTINCT occupation_standards.id) DESC"))
      .limit(limit)
  end
end
