class RegistrationAgency < ApplicationRecord
  validates :agency_type, presence: true
  validates :state, uniqueness: {scope: :agency_type}

  belongs_to :state, optional: true
  has_many :occupation_standards

  enum :agency_type, [:oa, :saa]

  OFFICE_OF_APPRENTICESHIP_STATE_ABBREVIATIONS = %w[
    AK
    AR
    AS
    CA
    FM
    GA
    ID
    IL
    IN
    MH
    MI
    MO
    MP
    MS
    ND
    NE
    NH
    NJ
    OK
    PW
    SC
    SD
    TX
    UT
    WV
    WY
  ].freeze

  STATE_APPRENTICESHIP_AGENCY_STATE_ABBREVIATIONS = %w[
    AL
    AZ
    CA
    CO
    CT
    DC
    DE
    FL
    GU
    HI
    IA
    KS
    KY
    LA
    MA
    MD
    ME
    MN
    MT
    NC
    NM
    NV
    NY
    OH
    OR
    PA
    RI
    TN
    VA
    VI
    VT
    WA
    WI
  ].freeze

  def to_s
    state_name = state&.name || "National"
    "#{state_name} (#{agency_type.upcase})"
  end

  def self.registration_agency_for_national_program
    find_by(state_id: nil)
  end

  def self.registration_agency_for_state(state, requested_agency_type: nil)
    agency_type = authoritative_agency_type_for_state(state, requested_agency_type: requested_agency_type)
    find_by(state: state, agency_type: agency_type) if agency_type
  end

  def self.authoritative_agency_type_for_state(state, requested_agency_type: nil)
    return if state.blank?

    if state.abbreviation == "CA"
      return requested_agency_type.presence || :oa
    end

    if STATE_APPRENTICESHIP_AGENCY_STATE_ABBREVIATIONS.include?(state.abbreviation)
      :saa
    elsif OFFICE_OF_APPRENTICESHIP_STATE_ABBREVIATIONS.include?(state.abbreviation)
      :oa
    else
      requested_agency_type
    end
  end
end
