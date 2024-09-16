class PdfToText
  def initialize(import_id)
    @pdf = Imports::Pdf.find(import_id)
  end

  def call
    @pdf.file.open do |io|
      reader = PDF::Reader.new(io)
      reader.pages.map(&:text).to_s
    end
  end
end
