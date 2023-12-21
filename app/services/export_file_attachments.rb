class ExportFileAttachments
  attr_reader :source_file

  TEMP_FILE_PATH = "#{Rails.root}/tmp/foo.zip"

  def initialize(source_file)
    @source_file = source_file
  end

  def call
    zip_file = create_zip_version_of_source_file
    file_names = unzip_attachments_and_list_file_names(zip_file)
    save_attachments_to_db(file_names)
    delete_extracted_files(file_names, zip_file)
  end

  private

  def create_zip_version_of_source_file
    zip_file = Tempfile.open(TEMP_FILE_PATH, encoding: "ascii-8bit")
    source_file.active_storage_attachment.blob.download { |chunk| zip_file.write(chunk) }
    zip_file
  end

  def unzip_attachments_and_list_file_names(zip_file)
    file_names = []

    Zip::File.open(zip_file) do |zip_file|
      zip_file.each do |entry|
        next unless entry.name.include?("docx") || entry.name.include?(".bin")
        entry.name.sub!(".bin", ".pdf")

        file_path = "#{Rails.root}/tmp/#{File.basename(entry.name)}"
        entry.extract(@entry_path = file_path)
        file_names << file_path
      end
    end

    file_names
  end

  def save_attachments_to_db(file_names)
    standards_import = StandardsImport.where(
      name: "Source File #{source_file.id}",
      organization: nil
    ).first_or_initialize(
      notes: "Extracted from Apprenticeship Bulletins",
      public_document: true,
      source_url: Rails.application.routes.url_helpers.admin_source_file_path(source_file)
    )

    if standards_import.new_record?
      standards_import.save!

      file_names.each do |file|
        standards_import.files.attach(io: File.open(file), filename: File.basename(file))
      end
    end
  end

  def delete_extracted_files(file_names, temp_file)
    temp_file.unlink
    file_names.each do |file|
      File.delete(file)
    end
  end
end
