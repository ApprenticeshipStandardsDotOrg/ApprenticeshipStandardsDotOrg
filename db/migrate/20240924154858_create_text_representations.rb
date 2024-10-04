class CreateTextRepresentations < ActiveRecord::Migration[7.2]
  def change
    create_table :text_representations, id: :uuid do |t|
      t.references :occupation_standard, null: false, foreign_key: true, type: :uuid
      t.text :content
      t.string :document_sha

      t.timestamps
    end
  end
end
