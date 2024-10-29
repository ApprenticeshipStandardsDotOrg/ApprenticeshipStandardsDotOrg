class CreateWordReplacements < ActiveRecord::Migration[7.2]
  def change
    create_table :word_replacements, id: :uuid do |t|
      t.string :word, null: false
      t.string :replacement, default: "****"

      t.timestamps
    end
  end
end
