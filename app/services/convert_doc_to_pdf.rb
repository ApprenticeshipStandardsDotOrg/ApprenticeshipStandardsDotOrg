class ConvertDocToPdf
  # @param import_id [UUID] ID for an Import, such as an Imports::Doc
  # @param import_file [ActiveStorage::Attached] the source file to convert
  #
  # @return [String] the pathname to the converted PDF
  #
  # @raise [PdfConversionError] either a +DependencyNotFoundError+ or
  #   +FileConversionError+
  def self.call(import_id, import_file, tmp_dir = TMP_DIRECTORY)
    new(import_id, import_file, tmp_dir).call
  end

  def initialize(import_id, import_file, tmp_dir)
    @import_id = import_id
    @import_file = import_file
    @tmp_dir = tmp_dir
  end

  def call
    verify_soffice_installed!
    dir = ensure_dir

    import_file.open do |file|
      run_command!(
        "soffice --headless --convert-to pdf #{file.path} --outdir #{dir}"
      )
      pdf_filename(dir, file)
    end
  end

  private

  attr_reader :import_id, :import_file, :tmp_dir

  TMP_DIRECTORY = "./tmp/soffice".freeze

  def verify_soffice_installed!
    unless Kernel.system("soffice --version")
      raise DependencyNotFoundError
    end
  end

  def run_command!(command)
    unless Kernel.system(command)
      raise FileConversionError
    end
  end

  def ensure_dir
    "#{tmp_dir}/#{import_id}".tap { FileUtils.mkdir_p(_1) }
  end

  def pdf_filename(dir, file)
    filename_without_ext = File.basename(file.path, ".*")
    "#{dir}/#{filename_without_ext}.pdf"
  end

  class PdfConversionError < StandardError
  end

  class DependencyNotFoundError < PdfConversionError
    def initialize(msg = "Libreoffice is not present in current path")
      super
    end
  end

  class FileConversionError < PdfConversionError
    def initialize(msg = "Could not convert the associated file to pdf")
      super
    end
  end
end
