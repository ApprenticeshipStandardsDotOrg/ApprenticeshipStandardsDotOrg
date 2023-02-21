class AddStatusToOccupationStandards < ActiveRecord::Migration[7.0]
  def change
    add_column :occupation_standards, :status, :integer, default: 0, null: false
  end
end
