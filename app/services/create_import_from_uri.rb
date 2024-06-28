class CreateImportFromUri
  def self.call(uri:, title:, notes:, source:, listing: false, metadata: {})
    new(uri:, title:, notes:, source:, listing:, metadata:).call
  end

  def initialize(uri:, title:, notes:, source:, listing:, metadata:)
    @uri = uri
    @title = title
    @notes = notes
    @source = source
    @listing = listing
    @metadata = metadata
  end

  def call
    standards_import = StandardsImport.where(
      name: uri,
      organization: title
    ).first_or_initialize(
      notes: notes,
      public_document: true,
      source_url: source,
      metadata: metadata
    )

    if standards_import.new_record?
      standards_import.save!

      import = standards_import.imports.create(
        type: "Imports::Uncategorized",
        public_document: true,
        metadata: standards_import.metadata,
        status: :unfurled
      )

      filename = File.basename(URI.decode_uri_component(uri))
      import.file.attach(io: URI.parse(uri).open, filename: filename)

      import.process(listing: listing)
    end
  end

  private

  attr_reader :uri, :title, :notes, :source, :listing, :metadata
end
