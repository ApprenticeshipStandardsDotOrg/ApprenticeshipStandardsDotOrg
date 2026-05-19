class AddSampleToOccupationStandards < ActiveRecord::Migration[8.0]
  def change
    add_column :occupation_standards, :sample, :boolean, null: false, default: false
    add_index :occupation_standards, :sample
  end
end
