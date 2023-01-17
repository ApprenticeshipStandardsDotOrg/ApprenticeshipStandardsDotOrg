class AddDefaultHoursToWorkProcess < ActiveRecord::Migration[7.0]
  def change
    add_column :work_processes, :default_hours, "int4range"
  end
end
