class AddUniquenessToOnetCode < ActiveRecord::Migration[7.0]
  def change
    add_index :onet_codes, [:code], unique: true, name: "unique_code"
  end
end
