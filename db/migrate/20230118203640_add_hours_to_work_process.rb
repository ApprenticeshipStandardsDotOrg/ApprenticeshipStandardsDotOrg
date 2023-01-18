class AddHoursToWorkProcess < ActiveRecord::Migration[7.0]
  def change
    add_column :work_processes, :hours, "int4range"
  end
end
