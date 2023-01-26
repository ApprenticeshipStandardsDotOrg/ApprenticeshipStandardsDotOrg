class AddDataImportIdToOccupationStandards < ActiveRecord::Migration[7.0]
  def change
    add_reference :occupation_standards, :data_import, null: true, foreign_key: true, type: :uuid
  end
end
