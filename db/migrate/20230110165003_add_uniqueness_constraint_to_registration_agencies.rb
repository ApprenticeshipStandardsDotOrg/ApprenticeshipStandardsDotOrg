class AddUniquenessConstraintToRegistrationAgencies < ActiveRecord::Migration[7.0]
  def change
    add_index :registration_agencies, [:state_id, :agency_type], unique: true
  end
end
