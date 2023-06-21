class WageStep < ApplicationRecord
  belongs_to :occupation_standard

  validates :title, presence: true
  validates :sort_order, uniqueness: {scope: :occupation_standard}
end
