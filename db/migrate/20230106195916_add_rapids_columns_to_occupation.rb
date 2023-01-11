class AddRapidsColumnsToOccupation < ActiveRecord::Migration[7.0]
  def change
    add_column :occupations, :rapids_code, :string
    add_column :occupations, :time_based_hours, :integer
    add_column :occupations, :hybrid_hours, :string
    add_column :occupations, :competency_based_hours, :integer
  end
end
