class CreateStandardsImports < ActiveRecord::Migration[7.0]
  def change
    create_table :standards_imports do |t|
      t.string :name
      t.string :email
      t.string :organization
      t.text :notes

      t.timestamps
    end
  end
end
