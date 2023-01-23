class WageStep < ApplicationRecord
  belongs_to :occupation_standard

  validates :sort_order, uniqueness: {scope: :occupation_standard}
end
