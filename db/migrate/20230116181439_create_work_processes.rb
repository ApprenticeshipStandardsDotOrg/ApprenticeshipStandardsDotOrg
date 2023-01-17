class CreateWorkProcesses < ActiveRecord::Migration[7.0]
  def change
    create_table :work_processes, id: :uuid do |t|
      t.string :title
      t.string :description
      t.references :occupation_standard, null: false, foreign_key: true, type: :uuid
      t.integer :default_hours
      t.integer :minimum_hours
      t.integer :maximum_hours
      t.integer :sort_order

      t.timestamps
    end
  end
end
