class AddProcessingToImports < ActiveRecord::Migration[7.1]
  def change
    add_column :imports, :processed_at, :timestamp, null: true
    add_column :imports, :processing_errors, :text, null: true
    add_index :imports, :processed_at
  end
end
