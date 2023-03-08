class ChangeNullFileImportOnDataImports < ActiveRecord::Migration[7.0]
  def change
    change_column_null :data_imports, :file_import_id, true
  end
end
