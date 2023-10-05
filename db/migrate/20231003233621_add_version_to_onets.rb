class AddVersionToOnets < ActiveRecord::Migration[7.0]
  def change
    add_column :onets, :version, :string
  end
end
