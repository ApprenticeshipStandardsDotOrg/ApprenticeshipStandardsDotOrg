class AddTermMonthsToOccupationStandards < ActiveRecord::Migration[7.0]
  def change
    add_column :occupation_standards, :term_months, :integer
  end
end
