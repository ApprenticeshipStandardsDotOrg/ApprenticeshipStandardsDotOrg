class RemoveMetadataConstraint < ActiveRecord::Migration[7.0]
  def change
    change_column_null :source_files, :metadata, true
  end
end
