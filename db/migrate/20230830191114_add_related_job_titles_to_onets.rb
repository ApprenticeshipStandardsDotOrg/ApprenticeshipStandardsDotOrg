class AddRelatedJobTitlesToOnets < ActiveRecord::Migration[7.0]
  def change
    add_column :onets, :related_job_titles, :string, array: true, default: []
  end
end
