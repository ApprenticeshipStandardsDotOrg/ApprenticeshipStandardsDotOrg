class RemoveFileImportIdFromDataImports < ActiveRecord::Migration[7.0]
  def change
    remove_reference :data_imports, :file_import, null: true, foreign_key: true, type: :uuid
  end
end
