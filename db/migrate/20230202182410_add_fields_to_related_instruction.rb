class AddFieldsToRelatedInstruction < ActiveRecord::Migration[7.0]
  def change
    add_reference :related_instructions, :organization, null: true, foreign_key: true, type: :uuid
    add_column :related_instructions, :code, :string
    add_column :related_instructions, :description, :string
  end
end
