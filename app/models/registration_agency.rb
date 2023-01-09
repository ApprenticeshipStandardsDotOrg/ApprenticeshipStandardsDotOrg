class RegistrationAgency < ApplicationRecord
  belongs_to :state

  enum agency_type: [:oa, :saa]
end
