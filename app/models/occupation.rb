class Occupation < ApplicationRecord
  validates :name, presence: true
  has_many :competency_options, as: :resource

  belongs_to :onet_code, optional: true
end
