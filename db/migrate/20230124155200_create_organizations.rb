class CreateOrganizations < ActiveRecord::Migration[7.0]
  def change
    create_table :organizations, id: :uuid do |t|
      t.string :title, null: false
      t.string :organization_type

      t.timestamps
    end
  end
end
