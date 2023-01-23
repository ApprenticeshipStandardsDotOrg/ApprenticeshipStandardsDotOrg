class RemoveRsiHoursFromOccupationStandards < ActiveRecord::Migration[7.0]
  def change
    remove_column :occupation_standards, :rsi_hours, :int4range
  end
end
