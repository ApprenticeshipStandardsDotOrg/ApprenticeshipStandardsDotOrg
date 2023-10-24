class CreateOnetMappings < ActiveRecord::Migration[7.0]
  def change
    create_table :onet_mappings, id: :uuid do |t|
      t.references :onet, null: false, foreign_key: true, type: :uuid
      t.references :next_version_onet, null: false, foreign_key: {to_table: :onets}, type: :uuid

      t.timestamps
    end
  end
end
