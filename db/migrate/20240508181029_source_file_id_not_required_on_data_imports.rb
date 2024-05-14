class SourceFileIdNotRequiredOnDataImports < ActiveRecord::Migration[7.1]
  def change
    change_column_null :data_imports, :source_file_id, true
  end
end
