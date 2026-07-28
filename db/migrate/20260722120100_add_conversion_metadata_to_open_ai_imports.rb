class AddConversionMetadataToOpenAIImports < ActiveRecord::Migration[8.1]
  def change
    add_column :open_ai_imports, :parsed_response, :jsonb, default: {}, null: false
    add_column :open_ai_imports, :extraction_errors, :jsonb, default: [], null: false
  end
end
