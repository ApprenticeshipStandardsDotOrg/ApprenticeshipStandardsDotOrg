class AddCourseIdToRelatedInstruction < ActiveRecord::Migration[7.0]
  def change
    add_reference :related_instructions, :course, null: true, foreign_key: true, type: :uuid
  end
end
