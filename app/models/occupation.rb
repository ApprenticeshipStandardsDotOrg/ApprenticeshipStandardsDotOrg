class Occupation < ApplicationRecord
  validates :name, presence: true

  belongs_to :onet_code, optional: true

  has_many :competency_options, as: :resource
end
