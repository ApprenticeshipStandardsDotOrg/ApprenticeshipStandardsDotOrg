class CreateImportFromUri
  def self.call(uri:, title:, notes:, source:, listing: false, date: nil)
    new(uri:, title:, notes:, source:, listing:, date:).call
  end

  def initialize(uri:, title:, notes:, source:, listing:, date:)
    @uri = uri
    @title = title
    @notes = notes
    @source = source
    @listing = listing
    @date = date
  end

  def call
    standards_import = StandardsImport.where(
      name: uri,
      organization: title
    ).first_or_initialize(
      notes: notes,
      public_document: true,
      source_url: source
    ).tap do |import|
      if date
        import[:metadata][:date] = date
      end
    end

    if standards_import.new_record?
      standards_import.save!

      import = standards_import.imports.create(
        type: "Imports::Uncategorized",
        public_document: true,
        metadata: standards_import.metadata
      )

      filename = File.basename(URI.decode_uri_component(uri))
      import.file.attach(io: URI.parse(uri).open, filename: filename)
      standards_import.files.attach(import.file_blob)

      import.process(listing: listing)
    end
  end

  private

  attr_reader :uri, :title, :notes, :source, :listing, :date
end
