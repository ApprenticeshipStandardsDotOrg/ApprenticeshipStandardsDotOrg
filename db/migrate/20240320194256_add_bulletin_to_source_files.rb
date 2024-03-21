class AddBulletinToSourceFiles < ActiveRecord::Migration[7.1]
  def change
    add_column :source_files, :bulletin, :boolean, default: false, null: false
  end
end
