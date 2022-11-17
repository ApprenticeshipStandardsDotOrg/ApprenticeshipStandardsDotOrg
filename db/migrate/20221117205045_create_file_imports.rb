class CreateFileImports < ActiveRecord::Migration[7.0]
  def change
    create_table :file_imports, id: :uuid do |t|
      t.references :active_storage_attachment, null: false, foreign_key: true, type: :uuid
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
