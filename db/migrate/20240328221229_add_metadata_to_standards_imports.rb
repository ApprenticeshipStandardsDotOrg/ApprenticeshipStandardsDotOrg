class AddMetadataToStandardsImports < ActiveRecord::Migration[7.1]
  def change
    add_column :standards_imports, :metadata, :jsonb, default: {}, null: false
  end
end
