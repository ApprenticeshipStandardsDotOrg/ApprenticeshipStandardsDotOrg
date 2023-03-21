class ChangeOccupationTypeToOjtType < ActiveRecord::Migration[7.0]
  def change
    rename_column :occupation_standards, :occupation_type, :ojt_type
  end
end
