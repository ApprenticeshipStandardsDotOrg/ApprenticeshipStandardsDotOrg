class WorkProcess < ApplicationRecord
  belongs_to :occupation_standard
  has_many :competencies, dependent: :destroy

  def hours
    [maximum_hours, minimum_hours].compact.first
  end
end
