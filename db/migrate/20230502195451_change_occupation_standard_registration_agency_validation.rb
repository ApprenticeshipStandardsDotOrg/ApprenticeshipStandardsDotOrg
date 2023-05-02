class ChangeOccupationStandardRegistrationAgencyValidation < ActiveRecord::Migration[7.0]
  def change
    change_column_null :occupation_standards, :registration_agency_id, true
  end
end
