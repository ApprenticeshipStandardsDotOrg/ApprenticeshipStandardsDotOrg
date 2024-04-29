class AddSponsorNumberToOrganization < ActiveRecord::Migration[7.1]
  def change
    add_column :organizations, :sponsor_number, :string
  end
end
