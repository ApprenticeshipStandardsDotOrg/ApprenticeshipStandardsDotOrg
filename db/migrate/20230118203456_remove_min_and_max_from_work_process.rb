class RemoveMinAndMaxFromWorkProcess < ActiveRecord::Migration[7.0]
  def change
    remove_column :work_processes, :minimum_hours
    remove_column :work_processes, :maximum_hours
  end
end
