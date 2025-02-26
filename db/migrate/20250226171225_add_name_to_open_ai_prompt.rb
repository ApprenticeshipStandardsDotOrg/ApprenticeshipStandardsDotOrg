class AddNameToOpenAIPrompt < ActiveRecord::Migration[8.0]
  def change
    add_column :open_ai_prompts, :name, :string, null: false
  end
end
