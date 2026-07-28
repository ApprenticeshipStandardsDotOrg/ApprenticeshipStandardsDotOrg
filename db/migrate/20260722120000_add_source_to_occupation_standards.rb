class AddSourceToOccupationStandards < ActiveRecord::Migration[8.1]
  def change
    add_column :occupation_standards, :source, :integer
    add_index :occupation_standards, :source
  end
end
