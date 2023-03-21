class AddStatusToDataImports < ActiveRecord::Migration[7.0]
  def change
    add_column :data_imports, :status, :integer, default: 0, null: false
  end
end
