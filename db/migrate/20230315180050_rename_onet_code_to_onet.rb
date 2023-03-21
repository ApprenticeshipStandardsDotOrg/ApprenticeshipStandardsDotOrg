class RenameOnetCodeToOnet < ActiveRecord::Migration[7.0]
  def change
    rename_table :onet_codes, :onets
  end
end
