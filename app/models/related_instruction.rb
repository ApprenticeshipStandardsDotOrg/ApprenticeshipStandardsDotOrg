class RelatedInstruction < ApplicationRecord
  belongs_to :occupation_standard
  belongs_to :course

  validates :sort_order, uniqueness: {scope: :occupation_standard}

  delegate :title, :description, :code, :hours, to: :course, prefix: true
  delegate :organization, to: :course, allow_nil: true

  def organization_title
    organization&.title
  end
end
