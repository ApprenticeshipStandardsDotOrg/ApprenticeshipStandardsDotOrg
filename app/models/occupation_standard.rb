class OccupationStandard < ApplicationRecord
  belongs_to :occupation, optional: true
  belongs_to :registration_agency
  belongs_to :organization, optional: true
  belongs_to :data_import, optional: true

  has_many :related_instructions, dependent: :destroy
  has_many :wage_steps, dependent: :destroy
  has_many :work_processes, dependent: :destroy

  delegate :name, to: :occupation, prefix: true, allow_nil: true

  enum occupation_type: [:time, :competency, :hybrid], _suffix: :based

  validates :title, presence: true

  def onet_code
    occupation&.onet_code&.code || read_attribute(:onet_code)
  end

  def rapids_code
    occupation&.rapids_code || read_attribute(:rapids_code)
  end
end
