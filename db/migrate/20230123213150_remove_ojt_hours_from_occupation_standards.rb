class RemoveOjtHoursFromOccupationStandards < ActiveRecord::Migration[7.0]
  def change
    remove_column :occupation_standards, :ojt_hours, :int4range
  end
end
