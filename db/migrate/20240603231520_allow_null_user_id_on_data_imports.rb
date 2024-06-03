class AllowNullUserIdOnDataImports < ActiveRecord::Migration[7.1]
  def change
    change_column_null(:data_imports, :user_id, true)
  end
end
