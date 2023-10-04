class AddIndexToCodeOnOnetsTable < ActiveRecord::Migration[7.0]
  def change
    add_index :onets, :code
  end
end
