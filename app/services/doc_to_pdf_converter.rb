class DocToPdfConverter
  TMP_DIRECTORY = "./tmp/soffice".freeze

  def self.convert(...) = new(...).convert

  def initialize(source_file, tmp_dir: TMP_DIRECTORY)
    @source_file = source_file
    @attachment = source_file.active_storage_attachment
    @standards_import = source_file.standards_import
    @tmp_dir = tmp_dir
  end

  def convert
    return unless source_file.can_be_converted_to_pdf?

    output_pdf_path = ConvertDocToPdf.call(
      source_file.id,
      attachment,
      tmp_dir,
    )

    ActiveRecord::Base.transaction do
      standards_import.files.attach(
        io: File.open(output_pdf_path),
        filename: pdf_filename,
        content_type: "application/pdf"
      )

      source_file.update!(link_to_pdf_filename: pdf_filename)
    end
  rescue ConvertDocToPdf::DependencyNotFoundError => e
    raise DependencyNotFoundError, e.message
  rescue ConvertDocToPdf::FileConversionError => e
    raise FileConversionError, e.message
  end

  private

  attr_reader :attachment
  attr_reader :source_file
  attr_reader :standards_import
  attr_reader :tmp_dir

  def pdf_filename
    "#{File.basename(attachment.filename.to_s, ".*")}.pdf"
  end

  class DependencyNotFoundError < StandardError
    def initialize(msg = "Libreoffice is not present in current path")
      super
    end
  end

  class FileConversionError < StandardError
    def initialize(msg = "Could not convert the associated file to pdf")
      super
    end
  end
end
