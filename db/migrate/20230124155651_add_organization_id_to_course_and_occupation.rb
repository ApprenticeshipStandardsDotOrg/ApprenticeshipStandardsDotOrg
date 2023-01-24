class AddOrganizationIdToCourseAndOccupation < ActiveRecord::Migration[7.0]
  def change
    add_reference :courses, :organization, null: true, foreign_key: true, type: :uuid
    add_reference :occupation_standards, :organization, null: true, foreign_key: true, type: :uuid
  end
end
