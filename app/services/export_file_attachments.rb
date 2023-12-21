class ExportFileAttachments
  attr_reader :source_file, :blob

  TEMP_FILE_PATH = "foo.zip"
  BULLETIN_LIST_URL = "https://www.apprenticeship.gov/about-us/legislation-regulations-guidance/bulletins/export?search=&category%5B0%5D=National%20Guideline%20Standards&category%5B1%5D=National%20Program%20Standards&category%5B2%5D=Occupations&page&_format=csv"

  def initialize(source_file, blob)
    @source_file = source_file
    @blob = blob
  end

  def call
    zip_file = create_zip_version_of_source_file
    file_names = unzip_attachments_and_list_file_names
    save_attachments_to_db(file_names)
    delete_extracted_files(file_names, zip_file)
  end

  private

  def create_zip_version_of_source_file
    zip_file = Tempfile.open(TEMP_FILE_PATH, encoding: "ascii-8bit")
    blob.download { |chunk| zip_file.write(chunk) }
    zip_file
  end

  def unzip_attachments_and_list_file_names
    file_names = []

    Zip::File.open(TEMP_FILE_PATH) do |zip_file|
      zip_file.each do |entry|
        next unless entry.name.include?("docx") || entry.name.include?(".bin")
        entry.name.sub!(".bin", ".pdf") if entry.name.include?(".bin")

        entry.extract
        file_names << entry.name
      end
    end

    file_names
  end

  def save_attachments_to_db(file_names)
    standards_import = StandardsImport.where(
      name: "Source File #{source_file.id}",
      organization: nil
    ).first_or_initialize(
      notes: "Extracted from Apprenticeship Bulletings",
      public_document: true,
      source_url: BULLETIN_LIST_URL
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
