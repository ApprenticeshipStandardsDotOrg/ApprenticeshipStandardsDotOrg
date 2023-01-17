class RemoveOnetCodeFromOccupations < ActiveRecord::Migration[7.0]
  def change
    remove_column :occupations, :onet_code, :string
  end
end
