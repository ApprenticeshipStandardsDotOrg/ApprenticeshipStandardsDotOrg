class AddRsiHoursToOccupationStandards < ActiveRecord::Migration[7.0]
  def change
    add_column :occupation_standards, :rsi_hours, :int4range
  end
end
