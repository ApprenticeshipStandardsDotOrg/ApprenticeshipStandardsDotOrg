class AddSourceFileIdToImports < ActiveRecord::Migration[7.1]
  def change
    add_reference :imports, :source_file, null: true, foreign_key: true, type: :uuid
  end
end
