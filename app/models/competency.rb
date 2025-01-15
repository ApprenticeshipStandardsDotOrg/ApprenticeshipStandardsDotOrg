class Competency < ApplicationRecord
  include JsonImportable

  belongs_to :work_process, counter_cache: true
  has_many :competency_options, as: :resource

  validates :sort_order, uniqueness: {scope: :work_process}

  class << self
    def from_json(json)
      from_open_ai_json(json)
    end
  end

  def sanitized_title
    ActionView::Base.full_sanitizer.sanitize(title)
  end
end
