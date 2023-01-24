class Course < ApplicationRecord
  belongs_to :organization

  validates :title, :code, uniqueness: {scope: :organization}
end
