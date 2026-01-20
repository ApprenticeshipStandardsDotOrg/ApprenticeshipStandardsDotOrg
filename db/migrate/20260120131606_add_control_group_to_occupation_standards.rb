class AddControlGroupToOccupationStandards < ActiveRecord::Migration[8.0]
  def change
    add_column :occupation_standards, :control_group, :boolean, default: false, null: false
    add_index :occupation_standards, :control_group
  end
end

