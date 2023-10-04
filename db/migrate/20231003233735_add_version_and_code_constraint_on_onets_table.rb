class AddVersionAndCodeConstraintOnOnetsTable < ActiveRecord::Migration[7.0]
  def up
    remove_index :onets, :code
    add_index :onets, [:version, :code], unique: true
  end

  def down
    remove_index :onets, [:version, :code]
    add_index :onets, :code, name: :unique_code, unique: true
  end
end
