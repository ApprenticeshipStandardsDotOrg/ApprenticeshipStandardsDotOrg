class OccupationStandard < ApplicationRecord
  belongs_to :occupation, optional: true
  belongs_to :registration_agency

  delegate :rapids_code, :onet_code, to: :occupation, allow_nil: true
end
