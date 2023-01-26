class AddOjtAndRsiHoursToOccupationStandards < ActiveRecord::Migration[7.0]
  def change
    add_column :occupation_standards, :ojt_hours_min, :integer
    add_column :occupation_standards, :ojt_hours_max, :integer
    add_column :occupation_standards, :rsi_hours_min, :integer
    add_column :occupation_standards, :rsi_hours_max, :integer
  end
end
