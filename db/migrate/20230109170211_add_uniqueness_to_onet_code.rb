class AddUniquenessToOnetCode < ActiveRecord::Migration[7.0]
  def change
    add_index :onet_codes, [:name, :code], unique: true, name: 'unique_name_per_code'
  end
end
