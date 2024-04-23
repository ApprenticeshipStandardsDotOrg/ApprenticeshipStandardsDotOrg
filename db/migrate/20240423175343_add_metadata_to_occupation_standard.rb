class AddMetadataToOccupationStandard < ActiveRecord::Migration[7.1]
  def change
    add_column :occupation_standards, :metadata, :jsonb, default: {}, null: false
  end
end
