class AddOnetCodeToOccupation < ActiveRecord::Migration[7.0]
  def change
    add_column :occupations, :onet_code, :string
  end
end
