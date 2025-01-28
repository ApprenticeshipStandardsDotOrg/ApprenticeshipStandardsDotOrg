class CreateOpenAIImports < ActiveRecord::Migration[8.0]
  def change
    create_table :open_ai_imports, id: :uuid do |t|
      t.references :import, null: false, foreign_key: true, type: :uuid
      t.references :occupation_standard, null: false, foreign_key: true, type: :uuid
      t.json :response

      t.timestamps
    end
  end
end
