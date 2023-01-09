class CreateRegistrationAgencies < ActiveRecord::Migration[7.0]
  def change
    create_table :registration_agencies, id: :uuid do |t|
      t.references :state, null: false, foreign_key: true, type: :uuid
      t.integer :agency_type

      t.timestamps
    end
  end
end
