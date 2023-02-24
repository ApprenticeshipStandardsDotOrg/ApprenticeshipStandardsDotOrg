class AddMetadataToFileImports < ActiveRecord::Migration[7.0]
  def change
    add_column :file_imports, :metadata, :jsonb
  end
end
