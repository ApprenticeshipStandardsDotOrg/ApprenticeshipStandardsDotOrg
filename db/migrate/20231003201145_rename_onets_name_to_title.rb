class RenameOnetsNameToTitle < ActiveRecord::Migration[7.0]
  def change
    rename_column :onets, :name, :title
  end
end
