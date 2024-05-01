class Scraper::ExportFileAttachmentsJob < ApplicationJob
  queue_as :default

  def perform(source_file)
    return if source_file.archived?

    DocxListingSplitter.split(source_file.id, source_file.active_storage_attachment) do |file_names|
      save_attachments_to_db(source_file, file_names)
    end

    source_file.archived!
  end

  private

  def save_attachments_to_db(source_file, file_names)
    return if file_names.empty?

    standards_import = source_file.standards_import
    existing_file_names = standards_import.files.map(&:filename)

    file_names.each do |file_name|
      basename = File.basename(file_name)
      next if existing_file_names.include?(basename)

      standards_import.files.attach(
        io: File.open(file_name),
        filename: basename
      )
    end
  end
end
