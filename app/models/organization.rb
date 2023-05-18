class Organization < ApplicationRecord
  has_one_attached :logo

  has_many :courses
  has_many :occupation_standards

  validates :title, presence: true, uniqueness: true

  def self.related_instructions_organizations(occupation_standard)
    where(id: occupation_standard.related_instructions.pluck(:organization_id)).distinct
  end

  def self.urban_institute
    Organization.find_by(title: "Urban Institute")
  end
end
