class AddVersionAndCodeConstraintOnOnetsTable < ActiveRecord::Migration[7.0]
  def change
    remove_index :onets, :code
    add_index :onets, [:version, :code], unique: true
  end
end
