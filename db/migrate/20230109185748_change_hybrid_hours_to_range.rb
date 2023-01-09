class ChangeHybridHoursToRange < ActiveRecord::Migration[7.0]
  def change
    change_column :occupations, :hybrid_hours, 'int4range USING CAST(hybrid_hours AS int4range)'
  end
end
