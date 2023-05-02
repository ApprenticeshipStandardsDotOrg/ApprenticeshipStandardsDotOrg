class AddNationalToOccupationStandard < ActiveRecord::Migration[7.0]
  def change
    add_column :occupation_standards, :national, :boolean
  end
end
