class AddDefaultToOpenAIPrompts < ActiveRecord::Migration[8.0]
  def up
    add_column :open_ai_prompts, :default, :boolean, null: false, default: false
    add_index :open_ai_prompts, :default, unique: true, where: "\"default\" = true"

    execute <<~SQL.squish
      UPDATE open_ai_prompts
      SET "default" = true
      WHERE id = (
        SELECT id
        FROM open_ai_prompts
        ORDER BY created_at ASC
        LIMIT 1
      )
    SQL
  end

  def down
    remove_index :open_ai_prompts, :default
    remove_column :open_ai_prompts, :default
  end
end
