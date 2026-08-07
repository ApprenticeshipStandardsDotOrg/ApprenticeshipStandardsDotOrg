require "administrate/field/base"

class SourceDocumentsField < Administrate::Field::Base
  def data
    resource.source_documents
  end

  def source_urls
    resource.source_urls
  end

  def linkable_url?(url)
    url.match?(/\Ahttps?:\/\//)
  end

  def to_s
    data.map(&:filename).join(", ")
  end
end
