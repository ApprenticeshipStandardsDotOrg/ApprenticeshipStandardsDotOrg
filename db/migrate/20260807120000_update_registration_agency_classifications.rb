class UpdateRegistrationAgencyClassifications < ActiveRecord::Migration[8.1]
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

  AGENCY_TYPES = {
    oa: 0,
    saa: 1
  }.freeze

  class MigrationState < ApplicationRecord
    self.table_name = "states"
  end

  class MigrationRegistrationAgency < ApplicationRecord
    self.table_name = "registration_agencies"

    belongs_to :state, class_name: "UpdateRegistrationAgencyClassifications::MigrationState", optional: true
  end

  class MigrationOccupationStandard < ApplicationRecord
    self.table_name = "occupation_standards"
  end

  def up
    expected_agencies.each do |abbreviation, agency_types|
      state = MigrationState.find_by(abbreviation: abbreviation)
      next unless state

      agency_types.each do |agency_type|
        MigrationRegistrationAgency.find_or_create_by!(
          state_id: state.id,
          agency_type: AGENCY_TYPES.fetch(agency_type)
        )
      end
    end

    reassign_stale_agencies
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def expected_agencies
    (OFFICE_OF_APPRENTICESHIP_STATE_ABBREVIATIONS + STATE_APPRENTICESHIP_AGENCY_STATE_ABBREVIATIONS)
      .uniq
      .index_with { |abbreviation| expected_agency_types_for(abbreviation) }
  end

  def expected_agency_types_for(abbreviation)
    return [:oa, :saa] if abbreviation == "CA"

    if STATE_APPRENTICESHIP_AGENCY_STATE_ABBREVIATIONS.include?(abbreviation)
      [:saa]
    elsif OFFICE_OF_APPRENTICESHIP_STATE_ABBREVIATIONS.include?(abbreviation)
      [:oa]
    else
      []
    end
  end

  def reassign_stale_agencies
    MigrationRegistrationAgency.includes(:state).find_each do |agency|
      state = agency.state
      next unless state

      expected_agency_types = expected_agency_types_for(state.abbreviation)
      next if expected_agency_types.empty?
      next if expected_agency_types.map { |type| AGENCY_TYPES.fetch(type) }.include?(agency.agency_type)

      replacement = MigrationRegistrationAgency.find_by!(
        state_id: state.id,
        agency_type: AGENCY_TYPES.fetch(expected_agency_types.first)
      )

      MigrationOccupationStandard
        .where(registration_agency_id: agency.id)
        .update_all(registration_agency_id: replacement.id)

      agency.destroy!
    end
  end
end
