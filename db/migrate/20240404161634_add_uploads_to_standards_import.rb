class AddUploadsToStandardsImport < ActiveRecord::Migration[7.1]
  def change
    create_table :imports, id: :uuid do |t|
      t.integer "status", default: 0, null: false
      t.references "assignee", foreign_key: {to_table: :users}, type: :uuid
      t.boolean "public_document", default: false, null: false
      t.integer "courtesy_notification", default: 0
      t.references "parent", polymorphic: true, null: false, type: :uuid
      t.string "type", null: false
      t.jsonb "metadata", default: {}
      t.timestamps
    end
  end
end
