class AddFileImportIdToDataImports < ActiveRecord::Migration[7.0]
  def change
    add_reference :data_imports, :file_import, null: false, foreign_key: true, type: :uuid
  end
end
