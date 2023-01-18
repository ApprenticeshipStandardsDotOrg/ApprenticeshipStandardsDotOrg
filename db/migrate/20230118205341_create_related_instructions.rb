class CreateRelatedInstructions < ActiveRecord::Migration[7.0]
  def change
    create_table :related_instructions, id: :uuid do |t|
      t.string :title
      t.int4range :hours
      t.boolean :elective
      t.integer :sort_order
      t.references :occupation_standard, null: false, foreign_key: true, type: :uuid
      t.integer :default_course_id

      t.timestamps
    end
  end
end
