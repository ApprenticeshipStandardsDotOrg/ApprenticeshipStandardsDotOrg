class CreateSynonyms < ActiveRecord::Migration[7.0]
  def change
    create_table :synonyms, id: :uuid do |t|
      t.string :word, null: false
      t.string :synonyms, null: false

      t.timestamps
    end
  end
end
