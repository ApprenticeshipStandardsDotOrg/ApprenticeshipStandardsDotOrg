class WordFile
  def self.content_types
    [
      Mime::Type.lookup_by_extension("docx").to_s,
      Mime::Type.lookup_by_extension("doc").to_s
    ]
  end

  def initialize(file)
    @file = file
  end
end
