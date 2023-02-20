class Occupation < ApplicationRecord
  has_many :competency_options, as: :resource

  belongs_to :onet_code, optional: true

  validates :name, presence: true

  def onet_soc_code
    onet_code&.code
  end

  def to_s
    "#{name} (#{rapids_code})"
  end
end
