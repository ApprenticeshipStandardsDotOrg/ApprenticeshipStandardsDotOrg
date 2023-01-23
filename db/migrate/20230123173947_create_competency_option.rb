class CreateCompetencyOption < ActiveRecord::Migration[7.0]
  def change
    create_table :competency_options, id: :uuid do |t|
      t.references :resource, null: false, type: :uuid, polymorphic: true
      t.string :title, null: false
      t.integer :sort_order, null: false

      t.timestamps
    end
  end
end
