class AddCompetencyOptionsCountToCompetencies < ActiveRecord::Migration[7.0]
  def change
    add_column :competencies, :competency_options_count, :integer, null: false, default: 0
  end
end
