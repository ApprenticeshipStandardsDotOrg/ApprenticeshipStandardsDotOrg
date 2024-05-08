class AddImportIdToDataImports < ActiveRecord::Migration[7.1]
  def change
    add_reference :data_imports, :import, null: true, foreign_key: true, type: :uuid
  end
end
