require "ole/storage"

class DocxListingSplitter
  def self.split(id, file, &)
    new(id, file).split(&)
  end

  def initialize(id, file)
    @id = id
    @file = file
  end

  def split(&block)
    zip_file = download_file
    file_names = unzip_attachments_and_list_file_names(zip_file)

    block.call(file_names)
  ensure
    delete_extracted_files(zip_file)
  end

  private

  def download_file
    zip_file = Tempfile.open(temp_file_path, encoding: "ascii-8bit")
    @file.blob.download { |chunk| zip_file.write(chunk) }
    zip_file
  end

  def unzip_attachments_and_list_file_names(zip_file)
    file_names = []

    unless File.zero?(zip_file)
      FileUtils.mkdir_p(Rails.root.join("tmp", @id))

      Zip::File.open(zip_file) do |zip_file|
        zip_file.each do |entry|
          if (file_path = save_entry(entry))
            file_names << file_path
          end
        end
      end
    end

    file_names
  end

  # @return [String] the path to a Doc or Docx file
  # @return [String] the path to a PDF file
  # @return [nil] don't know how to handle this kind of file
  def save_entry(entry)
    unless entry.name.end_with?(".doc", ".docx", ".bin")
      return
    end

    file_path = Rails.root.join("tmp", @id, File.basename(entry.name)).to_s
    entry.extract(file_path)

    if entry.name.end_with?(".bin")
      # .bin files are OLE storage containers holding arbitrary bytes. We only
      # expect them to store PDFs, so extract them assuming that.
      Ole::Storage.open(file_path, "r") do |ole|
        if ole.dir.entries(".").include?("CONTENTS")
          pdf_path = file_path.sub(/\.bin$/, ".pdf")
          contents = ole.file.read("CONTENTS")
          contents.force_encoding(Encoding::UTF_8)

          File.write(pdf_path, contents)

          pdf_path
        end
      end
    else
      file_path
    end
  end

  def delete_extracted_files(temp_file)
    temp_file.unlink
    FileUtils.rm_rf(Rails.root.join("tmp", @id).to_s)
  end

  def temp_file_path
    Rails.root.join("tmp", "#{@id}.zip").to_s
  end
end
