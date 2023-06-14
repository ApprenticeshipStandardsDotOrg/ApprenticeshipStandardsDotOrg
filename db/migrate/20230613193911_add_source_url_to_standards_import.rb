class AddSourceUrlToStandardsImport < ActiveRecord::Migration[7.0]
  def change
    add_column :standards_imports, :source_url, :string
  end
end
