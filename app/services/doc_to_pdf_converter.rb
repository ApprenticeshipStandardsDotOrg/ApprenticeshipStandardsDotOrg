class DocToPdfConverter
  TMP_DIRECTORY = "./tmp/soffice".freeze

  def self.convert_all
    SourceFile
      .docx_attachment
      .where.missing(:redacted_source_file_attachment)
      .select(:id)
      .find_each { ConvertJob.perform_later(_1) }
  end

  def self.convert(...) = new(...).convert

  def initialize(source_file, tmp_dir: TMP_DIRECTORY)
    @source_file = source_file
    @attachment = source_file.active_storage_attachment
    @tmp_dir = tmp_dir
  end

  def convert
    raise DependencyNotFoundError unless Kernel.system("command -v soffice")
    dir = ensure_dir

    attachment.open do |file|
      next if DocxFile.has_embedded_files?(file)

      command = "soffice --headless --convert-to pdf #{file.path} --outdir #{dir}"
      raise FileConversionError unless Kernel.system(command)

      filename_without_ext = File.basename(file.path, ".*")
      output_pdf_path = "#{dir}/#{filename_without_ext}.pdf"

      source_file.redacted_source_file.attach(
        io: File.open(output_pdf_path),
        filename: pdf_filename,
        content_type: "application/pdf"
      )
    end
  end

  private

  attr_reader :attachment
  attr_reader :source_file
  attr_reader :tmp_dir

  def ensure_dir
    "#{tmp_dir}/#{source_file.id}".tap { FileUtils.mkdir_p(_1) }
  end

  def pdf_filename
    # file.docx -> file.pdf
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

  class ConvertJob < ApplicationJob
    queue_as :default
    sidekiq_options retry: 0

    def peform(source_file) = DocToPdfConverter.convert(source_file)
  end
end
