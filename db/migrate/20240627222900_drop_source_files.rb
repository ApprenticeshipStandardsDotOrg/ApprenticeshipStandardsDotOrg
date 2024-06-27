class DropSourceFiles < ActiveRecord::Migration[7.1]
  def change
    drop_table :source_files
  end
end
