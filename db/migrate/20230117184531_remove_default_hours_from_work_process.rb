class RemoveDefaultHoursFromWorkProcess < ActiveRecord::Migration[7.0]
  def change
    remove_column :work_processes, :default_hours
  end
end
