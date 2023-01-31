class RemoveDefaultCourseIdFromRelatedInstructions < ActiveRecord::Migration[7.0]
  def change
    remove_column :related_instructions, :default_course_id, :integer
  end
end
