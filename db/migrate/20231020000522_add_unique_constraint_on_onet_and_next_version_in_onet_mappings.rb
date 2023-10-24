class AddUniqueConstraintOnOnetAndNextVersionInOnetMappings < ActiveRecord::Migration[7.0]
  def change
    remove_index :onet_mappings, :onet_id
    add_index :onet_mappings, [:onet_id, :next_version_onet_id], unique: true
  end
end
