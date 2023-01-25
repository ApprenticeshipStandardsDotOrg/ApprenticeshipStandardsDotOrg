class Course < ApplicationRecord
  belongs_to :organization, optional: true

  validates :title, :code, uniqueness: {scope: :organization}
end
