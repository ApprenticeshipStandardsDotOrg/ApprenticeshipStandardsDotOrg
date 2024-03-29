class Scraper::ExportFileAttachmentsJob < ApplicationJob
  queue_as :default

  attr_reader :source_file

  def perform(source_file)
    return if source_file.archived?

    @source_file = source_file

    zip_file = create_zip_version_of_source_file
    file_names = unzip_attachments_and_list_file_names(zip_file)
    save_attachments_to_db(file_names)
    delete_extracted_files(file_names, zip_file)
    source_file.archived!
  end

  private

  def temp_file_path
    Rails.root.join("tmp", "#{source_file.id}.zip").to_s
  end

  def create_zip_version_of_source_file
    zip_file = Tempfile.open(temp_file_path, encoding: "ascii-8bit")
    source_file.active_storage_attachment.blob.download { |chunk| zip_file.write(chunk) }
    zip_file
  end

  def unzip_attachments_and_list_file_names(zip_file)
    file_names = []

    unless File.zero?(zip_file)
      Zip::File.open(zip_file) do |zip_file|
        zip_file.each do |entry|
          next unless entry.name.end_with?(".doc", ".docx", ".bin")
          entry.name.sub!(".bin", ".pdf")

          FileUtils.mkdir_p(Rails.root.join("tmp", source_file.id))
          file_path = Rails.root.join("tmp", source_file.id, File.basename(entry.name)).to_s
          entry.extract(@entry_path = file_path)
          file_names << file_path
        end
      end
    end

    file_names
  end

  def save_attachments_to_db(file_names)
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

  def delete_extracted_files(file_names, temp_file)
    temp_file.unlink
    file_names.each do |file_name|
      File.delete(file_name)
    end
  end
end
