class AddRedactedAtToSourceFile < ActiveRecord::Migration[7.1]
  def change
    add_column :source_files, :redacted_at, :datetime
  end
end
