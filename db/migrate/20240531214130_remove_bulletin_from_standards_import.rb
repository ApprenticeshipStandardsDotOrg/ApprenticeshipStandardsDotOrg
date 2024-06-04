class RemoveBulletinFromStandardsImport < ActiveRecord::Migration[7.1]
  def change
    remove_column :standards_imports, :bulletin, :boolean, default: false, null: false
  end
end
