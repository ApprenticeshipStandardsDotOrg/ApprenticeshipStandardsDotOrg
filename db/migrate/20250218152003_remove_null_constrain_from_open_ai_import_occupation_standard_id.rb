class RemoveNullConstrainFromOpenAIImportOccupationStandardId < ActiveRecord::Migration[8.0]
  def change
    change_column_null :open_ai_imports, :occupation_standard_id, true
  end
end
