class CreateAIComparisonResults < ActiveRecord::Migration[8.0]
  def change
    create_table :ai_comparison_results, id: :uuid do |t|
      t.references :occupation_standard, null: false, foreign_key: true, type: :uuid, index: {unique: true}
      t.decimal :work_processes_score, precision: 5, scale: 2
      t.decimal :related_instructions_score, precision: 5, scale: 2
      t.decimal :overall_score, precision: 5, scale: 2
      t.boolean :needs_review, default: false, null: false
      t.boolean :flagged_by_system, default: false, null: false
      t.boolean :flagged_by_user, default: false, null: false
      t.text :work_processes_comparison_details
      t.text :related_instructions_comparison_details
      t.text :notes

      t.timestamps
    end
    add_index :ai_comparison_results, :overall_score
    add_index :ai_comparison_results, :needs_review
    add_index :ai_comparison_results, [:flagged_by_system, :flagged_by_user]
  end
end
