class CreateOpenAIPrompts < ActiveRecord::Migration[8.0]
  def change
    create_table :open_ai_prompts, id: :uuid do |t|
      t.text :prompt, null: false

      t.timestamps
    end
  end
end
