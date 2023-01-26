class AddOnetCodeAndRapidsCodeToOccupationStandards < ActiveRecord::Migration[7.0]
  def change
    add_column :occupation_standards, :onet_code, :string
    add_column :occupation_standards, :rapids_code, :string
  end
end
