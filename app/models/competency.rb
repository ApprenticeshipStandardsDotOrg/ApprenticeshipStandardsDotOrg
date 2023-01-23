class Competency < ApplicationRecord
  belongs_to :work_process

  validates :sort_order, uniqueness: {scope: :work_process}

  has_many :competency_options, as: :resource
end
