class State < ApplicationRecord
  has_many :registration_agencies
  has_many :occupation_standards, through: :registration_agencies

  def occupation_standards_count
    (occupation_standards.count > 0) ? occupation_standards.count : ""
  end
end
