class WorkProcess < ApplicationRecord
  belongs_to :occupation_standard
  has_many :competencies, dependent: :destroy
end
