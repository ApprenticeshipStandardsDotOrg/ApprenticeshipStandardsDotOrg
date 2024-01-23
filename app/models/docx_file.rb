class DocxFile
  def self.has_embedded_files?(...) = new(...).has_embedded_files?

  def initialize(file)
    @file = file
  end

  def has_embedded_files?
    zip_file&.entries&.any? { _1.name.start_with?("word/embeddings") }
  end

  private

  attr_reader :file

  def zip_file
    @_zip_file ||= File.zero?(file) ? nil : Zip::File.open(file)
  end
end
