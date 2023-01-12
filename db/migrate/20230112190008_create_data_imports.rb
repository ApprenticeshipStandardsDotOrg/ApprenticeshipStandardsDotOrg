class CreateDataImports < ActiveRecord::Migration[7.0]
  def change
    create_table :data_imports, id: :uuid do |t|
      t.string :description
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
