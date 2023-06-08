class RegistrationAgency < ApplicationRecord
  validates :agency_type, presence: true
  validates :state, uniqueness: {scope: :agency_type}

  belongs_to :state, optional: true

  enum agency_type: [:oa, :saa]

  def to_s
    "#{state.name} (#{agency_type.upcase})"
  end
end
