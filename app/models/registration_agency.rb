class RegistrationAgency < ApplicationRecord
  validates :agency_type, presence: true
  validates :state, uniqueness: {scope: :agency_type}

  belongs_to :state, optional: true
  has_many :occupation_standards

  enum agency_type: [:oa, :saa]

  def to_s
    state_name = state&.name || "National"
    "#{state_name} (#{agency_type.upcase})"
  end
end
