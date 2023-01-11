class CreateStates < ActiveRecord::Migration[7.0]
  def change
    create_table :states, id: :uuid do |t|
      t.string :name
      t.string :abbreviation

      t.timestamps
    end
  end
end
