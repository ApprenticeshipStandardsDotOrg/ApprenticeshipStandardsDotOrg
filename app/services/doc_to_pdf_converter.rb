class DocToPdfConverter
  TMP_DIRECTORY = "./tmp/soffice".freeze

  def self.call(source_file)
    raise DependencyNotFoundError unless Kernel.system("command -v soffice")

    Dir.mkdir(TMP_DIRECTORY) unless Dir.exist?(TMP_DIRECTORY)

    source_file.active_storage_attachment.open do |file|
      _filename = File.basename(file.path, ".*")
      command = "soffice --headless --convert-to pdf #{file.path} --outdir #{TMP_DIRECTORY}"
      result = Kernel.system(command)

      if result
        true
        # TODO: add actual implementation. As an example, here's how you can
        # attach the file to the source file as the redacted_source_file
        # source_file.redacted_source_file.attach(
        # io: File.open("#{TMP_DIRECTORY}/#{_filename}.pdf"),
        # filename: "#{_filename}.pdf",
        # content_type: 'application/pdf'
        # )
      else
        raise FileConversionError
      end
    end
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
