class AddOccupationTypeToOccupationStandards < ActiveRecord::Migration[7.0]
  def change
    add_column :occupation_standards, :occupation_type, :integer
  end
end
