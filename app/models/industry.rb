class Industry < ApplicationRecord
  CURRENT_VERSION = "2018"

  has_many :occupation_standards

  validates :name, :version, presence: true
  validates :prefix, presence: true, uniqueness: {scope: :version}

  scope :current, -> { where(version: CURRENT_VERSION) }

  def self.popular(limit: 4)
    Industry.left_joins(:occupation_standards)
      .group("industries.id")
      .order("COUNT(occupation_standards.id) DESC")
      .limit(limit)
  end
end
