class OccupationStandard < ApplicationRecord
  belongs_to :occupation, optional: true
  belongs_to :registration_agency

  delegate :rapids_code, to: :occupation, allow_nil: true

  def onet_code
    occupation&.onet_code&.code
  end
end
