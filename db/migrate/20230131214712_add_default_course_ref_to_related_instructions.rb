class AddDefaultCourseRefToRelatedInstructions < ActiveRecord::Migration[7.0]
  def change
    add_reference :related_instructions, :default_course, null: true, foreign_key: {to_table: :courses}, type: :uuid
  end
end
