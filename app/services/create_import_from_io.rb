class CreateImportFromIo
  def self.call(io:, filename:, title:, notes: nil, source:, listing: false, metadata: {})
    new(io:, filename:, title:, notes:, source:, listing:, metadata:).call
  end

  def initialize(io:, filename:, title:, notes:, source:, listing:, metadata:)
    @io = io
    @filename = filename
    @title = title
    @notes = notes
    @source = source
    @listing = listing
    @metadata = metadata
  end

  def call
    standards_import = StandardsImport.where(
      name: filename,
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

      import.file.attach(io: io, filename: filename)
      standards_import.files.attach(import.file_blob)

      import.tap do |import|
        import.process(listing: listing)
      end
    end
  end

  private

  attr_reader :io, :filename, :title, :notes, :source, :listing, :metadata
end
