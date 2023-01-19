class CreateCompetencyEvaluationOptions < ActiveRecord::Migration[7.0]
  def change
    create_table :competency_evaluation_options, id: :uuid do |t|
      t.references :resource, null: false, type: :uuid, polymorphic: true
      t.string :title
      t.integer :sort_order

      t.timestamps
    end
  end
end
