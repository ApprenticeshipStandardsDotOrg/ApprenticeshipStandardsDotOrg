class AddApprenticeshipToJourneyworkerRatioToOccupationStandards < ActiveRecord::Migration[7.0]
  def change
    add_column :occupation_standards, :apprenticeship_to_journeyworker_ratio, :float
  end
end
