class Course < ApplicationRecord
  belongs_to :organization, optional: true

  validates :title, :code, uniqueness: {scope: :organization}

  delegate :title, to: :organization, prefix: true
end
