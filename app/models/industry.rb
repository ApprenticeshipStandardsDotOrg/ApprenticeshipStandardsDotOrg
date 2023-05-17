class Industry < ApplicationRecord
  has_many :occupation_standards

  validates :name, :version, presence: true
  validates :prefix, presence: true, uniqueness: {scope: :version}
end
