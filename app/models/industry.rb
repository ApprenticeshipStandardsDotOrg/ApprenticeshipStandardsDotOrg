class Industry < ApplicationRecord
  validates :name, :version, :prefix, presence: true
end
