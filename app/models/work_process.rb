class WorkProcess < ApplicationRecord
  include ActionView::Helpers::NumberHelper

  belongs_to :occupation_standard
  has_many :competencies, -> { order(:sort_order) }, dependent: :destroy

  validates :title, presence: true

  delegate :work_processes_hours, to: :occupation_standard, prefix: true, allow_nil: true

  accepts_nested_attributes_for :competencies, allow_destroy: true

  def hours
    [maximum_hours, minimum_hours].compact.first
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
    description.present? || competencies.any?
  end
end
