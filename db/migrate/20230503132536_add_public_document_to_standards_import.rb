class AddPublicDocumentToStandardsImport < ActiveRecord::Migration[7.0]
  def change
    add_column :standards_imports, :public_document, :boolean, default: false, null: false
  end
end
