class Organization < ApplicationRecord
  has_one_attached :file

  has_many :courses
  has_many :occupation_standards

  validates :title, presence: true, uniqueness: true
end
