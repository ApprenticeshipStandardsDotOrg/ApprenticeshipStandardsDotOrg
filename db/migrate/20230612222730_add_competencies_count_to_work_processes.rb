class AddCompetenciesCountToWorkProcesses < ActiveRecord::Migration[7.0]
  def change
    add_column :work_processes, :competencies_count, :integer, null: false, default: 0
  end
end
