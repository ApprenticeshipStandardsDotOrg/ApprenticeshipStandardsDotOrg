class AddRegistrationDateAndRegistrationLatestUpdateDateToOccupationStandard < ActiveRecord::Migration[7.0]
  def change
    add_column :occupation_standards, :registration_date, :date
    add_column :occupation_standards, :latest_update_date, :date
  end
end
