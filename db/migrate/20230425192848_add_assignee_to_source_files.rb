class AddAssigneeToSourceFiles < ActiveRecord::Migration[7.0]
  def change
    add_reference :source_files, :assignee, null: true, foreign_key: {to_table: :users}, type: :uuid
  end
end
