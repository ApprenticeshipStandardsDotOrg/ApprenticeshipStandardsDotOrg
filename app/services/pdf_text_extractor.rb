require "open3"
require "tempfile"

class PdfTextExtractor
  def initialize(file)
    @file = file
  end

  def call
    layout_text.presence || pdf_reader_text
  end

  private

  attr_reader :file

  def layout_text
    return unless pdftotext_available?

    file.open do |io|
      Tempfile.create(["pdf-text-extractor", ".pdf"], binmode: true) do |pdf|
        IO.copy_stream(io, pdf)
        pdf.flush

        text, status = Open3.capture2("pdftotext", "-layout", "-enc", "UTF-8", pdf.path, "-")
        text if status.success?
      end
    end
  rescue SystemCallError
    nil
  end

  def pdf_reader_text
    file.open do |io|
      reader = PDF::Reader.new(io)
      reader.pages.each_with_index.map do |page, index|
        "--- Page #{index + 1} ---\n#{page.text}"
      end.join("\n\n")
    end
  end

  def pdftotext_available?
    _, status = Open3.capture2("pdftotext", "-v")
    status.success? || status.exitstatus == 99
  rescue SystemCallError
    false
  end
end
