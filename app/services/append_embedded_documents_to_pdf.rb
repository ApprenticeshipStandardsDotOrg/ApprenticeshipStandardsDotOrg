require "open3"
require "digest"

class AppendEmbeddedDocumentsToPdf
  def self.call(source_path:, pdf_path:, depth: 0)
    Dir.mktmpdir("embedded-documents") do |directory|
      result = ExtractEmbeddedDocuments.call(source_path, directory: directory)
      unless result.unsupported.empty?
        raise ConvertDocToPdf::FileConversionError, "Unsupported embedded documents: #{result.unsupported.join("; ")}"
      end
      return pdf_path if result.paths.empty?

      raise ConvertDocToPdf::FileConversionError, "Embedded documents exceed nesting limit" if depth >= 5

      payloads = result.paths.uniq { |path| Digest::SHA256.file(path).hexdigest }
      attachments = payloads.map do |path|
        next path if path.end_with?(".pdf")

        run!("soffice", "--headless", "-env:UserInstallation=file://#{directory}/profile", "--convert-to", "pdf", "--outdir", directory, path)
        converted = path.sub(/\.[^.]+$/, ".pdf")
        raise ConvertDocToPdf::FileConversionError, "Embedded document conversion produced no PDF" unless File.file?(converted)

        call(source_path: path, pdf_path: converted, depth: depth + 1)
      end
      merged = File.join(directory, "merged.pdf")
      run!("pdfunite", pdf_path.to_s, *attachments, merged)
      FileUtils.cp(merged, pdf_path)
    end
    pdf_path
  end

  def self.run!(*command)
    output, status = Open3.capture2e(*command)
    raise ConvertDocToPdf::FileConversionError, "Embedded document conversion failed: #{output}" unless status.success?
  rescue Errno::ENOENT => error
    raise ConvertDocToPdf::DependencyNotFoundError, error.message
  end
  private_class_method :run!
end
