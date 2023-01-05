class OnetCode < ApplicationRecord
  validates :name, :code, presence: true
end
