class PdfFile < SimpleDelegator

  alias_method :pdf_reader, :__getobj__

  def self.text(filepath)
    new(PDF::Reader.new(filepath)).text
  end

  def text
    pdf_reader.pages&.map(&:text).join('\n')
  end
end
