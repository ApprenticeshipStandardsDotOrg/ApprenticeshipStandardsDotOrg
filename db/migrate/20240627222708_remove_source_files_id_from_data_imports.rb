class RemoveSourceFilesIdFromDataImports < ActiveRecord::Migration[7.1]
  def change
    remove_reference :data_imports, :source_file, null: true, foreign_key: true, type: :uuid
  end
end
