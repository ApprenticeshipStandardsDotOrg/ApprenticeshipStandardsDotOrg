class RelatedInstruction < ApplicationRecord
  include ActionView::Helpers::NumberHelper
  include JsonImportable

  belongs_to :occupation_standard
  belongs_to :organization, optional: true
  belongs_to :default_course, class_name: "Course", optional: true

  validates :sort_order, presence: true, uniqueness: {scope: [:occupation_standard, :title, :code]}
  validates :title, presence: true

  delegate :title, :description, :code, :hours, to: :default_course, prefix: true
  delegate :title, to: :organization, prefix: true

  class << self
    def from_json(json)
      from_open_ai_json(json, exclude_fields: ["organization"])
    end
  end

  def hours_in_human_format
    number_to_human(
      hours,
      format: "%n%u",
      precision: 2,
      units:
      {
        thousand: "K"
      }
    )
  end

  def has_details_to_display?
    description.present?
  end
end
