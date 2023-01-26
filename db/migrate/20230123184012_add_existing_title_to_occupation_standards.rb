class AddExistingTitleToOccupationStandards < ActiveRecord::Migration[7.0]
  def change
    add_column :occupation_standards, :existing_title, :string
  end
end
