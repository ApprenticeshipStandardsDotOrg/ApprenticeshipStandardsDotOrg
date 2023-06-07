class ChangeRegistrationAgencyValidation < ActiveRecord::Migration[7.0]
  def change
    change_column_null :registration_agencies, :state_id, true
  end
end
