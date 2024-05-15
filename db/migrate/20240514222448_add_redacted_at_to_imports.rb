class AddRedactedAtToImports < ActiveRecord::Migration[7.1]
  def change
    add_column :imports, :redacted_at, :timestamp
  end
end
