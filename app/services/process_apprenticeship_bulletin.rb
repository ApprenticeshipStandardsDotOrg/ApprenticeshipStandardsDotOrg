class ProcessApprenticeshipBulletin
  def self.call(uri:, title:, date:)
    new(uri:, title:, date:).call
  end

  def initialize(uri:, title:, date:)
    @uri = uri
    @title = title
    @date = date
  end

  def call
    standards_import = StandardsImport.where(
      name: uri,
      organization: title
    ).first_or_initialize(
      notes: "From Scraper::ApprenticeshipBulletinsJob",
      public_document: true,
      source_url: Scraper::ApprenticeshipBulletinsJob::BULLETIN_LIST_URL,
      bulletin: true,
      metadata: {date: date}
    )

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

      import.process(listing: true)
    end
  end

  private

  attr_reader :uri, :title, :date
end
