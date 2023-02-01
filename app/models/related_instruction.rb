class RelatedInstruction < ApplicationRecord
  belongs_to :occupation_standard
  belongs_to :default_course, class_name: "Course", optional: true

  validates :sort_order, :title, uniqueness: {scope: :occupation_standard}

  delegate :title, :description, :code, :hours, to: :course, prefix: true
  delegate :organization, to: :course, allow_nil: true

  def organization_title
    organization&.title
  end
end
