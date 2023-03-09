class AddSourceFileIdToDataImports < ActiveRecord::Migration[7.0]
  def change
    DataImport.destroy_all
    OccupationStandard.destroy_all
    add_reference :data_imports, :source_file, null: false, foreign_key: true, type: :uuid
  end
end
