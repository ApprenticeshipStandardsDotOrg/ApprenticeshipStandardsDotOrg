class OnetCode < ApplicationRecord
  validates :name, :code, presence: true
  validates :code, uniqueness: true
end
