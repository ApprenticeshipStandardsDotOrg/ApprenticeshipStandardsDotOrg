class AddProbationaryPeriodMonthsToOccupationStandards < ActiveRecord::Migration[7.0]
  def change
    add_column :occupation_standards, :probationary_period_months, :integer
  end
end
