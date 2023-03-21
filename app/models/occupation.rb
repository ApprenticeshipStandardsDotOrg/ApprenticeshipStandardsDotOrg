class Occupation < ApplicationRecord
  has_many :competency_options, as: :resource

  belongs_to :onet, optional: true

  validates :title, presence: true

  delegate :code, to: :onet, prefix: true, allow_nil: true

  def to_s
    "#{title} (#{rapids_code})"
  end
end
