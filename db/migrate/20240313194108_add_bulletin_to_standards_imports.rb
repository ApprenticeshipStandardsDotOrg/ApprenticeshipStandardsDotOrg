class AddBulletinToStandardsImports < ActiveRecord::Migration[7.1]
  def change
    add_column :standards_imports, :bulletin, :boolean, default: false, null: false
  end
end
