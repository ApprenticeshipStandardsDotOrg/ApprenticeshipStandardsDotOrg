class CreateWageSteps < ActiveRecord::Migration[7.0]
  def change
    create_table :wage_steps, id: :uuid do |t|
      t.references :occupation_standard, null: false, foreign_key: true, type: :uuid
      t.integer :sort_order
      t.string :title
      t.integer :minimum_hours
      t.decimal :ojt_percentage
      t.integer :duration_in_months
      t.integer :rsi_hours

      t.timestamps
    end
  end
end
