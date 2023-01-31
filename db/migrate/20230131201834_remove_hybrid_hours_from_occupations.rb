class RemoveHybridHoursFromOccupations < ActiveRecord::Migration[7.0]
  def change
    remove_column :occupations, :hybrid_hours, :int4range
  end
end
