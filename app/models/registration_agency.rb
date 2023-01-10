class RegistrationAgency < ApplicationRecord
  validates :agency_type, presence: true
  validates :state, uniqueness: {scope: :agency_type}

  belongs_to :state

  enum agency_type: [:oa, :saa]
end
