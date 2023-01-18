class AddSponsorNameToOccupationStandards < ActiveRecord::Migration[7.0]
  def change
    add_column :occupation_standards, :sponsor_name, :string
  end
end
