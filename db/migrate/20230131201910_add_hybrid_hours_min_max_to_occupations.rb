class AddHybridHoursMinMaxToOccupations < ActiveRecord::Migration[7.0]
  def change
    add_column :occupations, :hybrid_hours_min, :integer
    add_column :occupations, :hybrid_hours_max, :integer
  end
end
