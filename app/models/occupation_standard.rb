class OccupationStandard < ApplicationRecord
  belongs_to :occupation, optional: true
  belongs_to :registration_agency
  belongs_to :organization, optional: true

  has_many :related_instructions
  has_many :wage_steps

  delegate :rapids_code, to: :occupation, allow_nil: true

  def onet_code
    occupation&.onet_code&.code
  end
end
