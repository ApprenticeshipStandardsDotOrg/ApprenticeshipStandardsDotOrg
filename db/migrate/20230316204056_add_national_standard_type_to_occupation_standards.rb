class AddNationalStandardTypeToOccupationStandards < ActiveRecord::Migration[7.0]
  def change
    add_column :occupation_standards, :national_standard_type, :integer
  end
end
