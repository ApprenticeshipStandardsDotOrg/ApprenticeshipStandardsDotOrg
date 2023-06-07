class MovePublicDocumentFromOccupationStandardToSourceFile < ActiveRecord::Migration[7.0]
  def change
    remove_column :occupation_standards, :public_document, :boolean, default: false, null: false
    add_column :source_files, :public_document, :boolean, default: false, null: false
  end
end
