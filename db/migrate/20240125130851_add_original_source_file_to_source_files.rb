class AddOriginalSourceFileToSourceFiles < ActiveRecord::Migration[7.1]
  def change
    add_column(:source_files, :link_to_pdf_filename, :string)
    add_reference(
      :source_files,
      :original_source_file,
      index: true,
      type: :uuid
    )
    add_foreign_key(
      :source_files,
      :source_files,
      column: :original_source_file_id,
      type: :uuid
    )
  end
end
