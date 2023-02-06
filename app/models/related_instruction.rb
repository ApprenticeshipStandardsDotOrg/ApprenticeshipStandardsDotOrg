class RelatedInstruction < ApplicationRecord
  belongs_to :occupation_standard
  belongs_to :organization, optional: true
  belongs_to :default_course, class_name: "Course", optional: true

  validates :sort_order, uniqueness: {scope: [:occupation_standard, :title, :code]}

  delegate :title, :description, :code, :hours, to: :default_course, prefix: true
  delegate :title, to: :organization, prefix: true
end
