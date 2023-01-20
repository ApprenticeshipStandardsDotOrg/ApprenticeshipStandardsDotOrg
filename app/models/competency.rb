class Competency < ApplicationRecord
  belongs_to :work_process

  validates :sort_order, uniqueness: {scope: :work_process}
end
