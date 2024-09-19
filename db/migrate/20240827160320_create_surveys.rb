class CreateSurveys < ActiveRecord::Migration[7.1]
  def change
    create_table :surveys, id: :uuid do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :organization, null: false

      t.timestamps
    end
  end
end
