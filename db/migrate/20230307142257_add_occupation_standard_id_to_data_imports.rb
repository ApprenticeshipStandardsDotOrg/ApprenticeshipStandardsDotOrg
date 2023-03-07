class AddOccupationStandardIdToDataImports < ActiveRecord::Migration[7.0]
  def change
    DataImport.destroy_all
    add_reference :data_imports, :occupation_standard, null: true, foreign_key: true, type: :uuid
  end
end
