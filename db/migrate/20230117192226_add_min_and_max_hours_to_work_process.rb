class AddMinAndMaxHoursToWorkProcess < ActiveRecord::Migration[7.0]
  def change
    add_column :work_processes, :minimum_hours, "int4range"
    add_column :work_processes, :maximum_hours, "int4range"
  end
end
