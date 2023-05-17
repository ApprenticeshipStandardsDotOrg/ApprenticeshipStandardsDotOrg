class Competency < ApplicationRecord
  belongs_to :work_process
  has_many :competency_options, as: :resource

  validates :sort_order, uniqueness: {scope: :work_process}

  def raw_title
    ActionView::Base.full_sanitizer.sanitize(title)
  end
end
