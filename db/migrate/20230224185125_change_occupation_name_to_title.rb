class ChangeOccupationNameToTitle < ActiveRecord::Migration[7.0]
  def change
    rename_column :occupations, :name, :title
  end
end
