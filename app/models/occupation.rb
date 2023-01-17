class Occupation < ApplicationRecord
  validates :name, presence: true

  belongs_to :onet_code, optional: true
end
