class AddSampleSetToOccupationStandards < ActiveRecord::Migration[8.0]
  def change
    add_column :occupation_standards, :sample_set, :boolean, null: false, default: false
    add_index :occupation_standards, :sample_set
  end
end
