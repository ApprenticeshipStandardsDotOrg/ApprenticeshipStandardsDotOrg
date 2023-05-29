class AddPublicDocumentToOccupationStandard < ActiveRecord::Migration[7.0]
  def change
    add_column :occupation_standards, :public_document, :boolean, default: false, null: false
  end
end
