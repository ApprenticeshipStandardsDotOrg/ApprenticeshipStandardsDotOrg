class CreateCompetencies < ActiveRecord::Migration[7.0]
  def change
    create_table :competencies, id: :uuid do |t|
      t.references :work_process, null: false, foreign_key: true, type: :uuid
      t.string :title
      t.text :description
      t.integer :sort_order

      t.timestamps
    end
  end
end
