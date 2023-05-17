class Industry < ApplicationRecord
  validates :name, :version, presence: true
  validates :prefix, presence: true, uniqueness: {scope: :version}
end
