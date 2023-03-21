class RenameOnetCodeIdToOnetIdInOccupations < ActiveRecord::Migration[7.0]
  def change
    rename_column :occupations, :onet_code_id, :onet_id
  end
end
