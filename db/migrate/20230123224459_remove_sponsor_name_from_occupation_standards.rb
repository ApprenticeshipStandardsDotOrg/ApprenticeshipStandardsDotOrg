class RemoveSponsorNameFromOccupationStandards < ActiveRecord::Migration[7.0]
  def change
    remove_column :occupation_standards, :sponsor_name, :string
  end
end
