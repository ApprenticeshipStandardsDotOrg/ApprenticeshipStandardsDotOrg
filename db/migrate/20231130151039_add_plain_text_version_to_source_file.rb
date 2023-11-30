class AddPlainTextVersionToSourceFile < ActiveRecord::Migration[7.1]
  def change
    add_column :source_files, :plain_text_version, :text
  end
end
