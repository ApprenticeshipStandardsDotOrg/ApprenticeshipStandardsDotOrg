class PdfFile < SimpleDelegator
  alias_method :pdf_reader, :__getobj__

  def self.text(...) = new(PDF::Reader.new(...)).text

  def text
    pdf_reader.pages&.map(&:text).to_s
  end
end
