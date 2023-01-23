class CreateCourses < ActiveRecord::Migration[7.0]
  def change
    create_table :courses, id: :uuid do |t|
      t.string :title
      t.string :description
      t.string :code
      t.decimal :units
      t.integer :hours

      t.timestamps
    end
  end
end
