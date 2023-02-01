class OccupationStandard < ApplicationRecord
  belongs_to :occupation, optional: true
  belongs_to :registration_agency
  belongs_to :organization, optional: true
  belongs_to :data_import, optional: true

  has_many :related_instructions
  has_many :wage_steps
  has_many :work_processes

  delegate :rapids_code, to: :occupation, allow_nil: true

  enum occupation_type: [:time, :competency, :hybrid], _suffix: :based

  def onet_code
    occupation&.onet_code&.code || read_attribute(:onet_code)
  end

  def rapids_code
    occupation&.rapids_code || read_attribute(:rapids_code)
  end
end
