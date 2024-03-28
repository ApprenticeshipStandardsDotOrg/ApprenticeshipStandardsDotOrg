class Scraper::ApprenticeshipBulletinsJob < ApplicationJob
  queue_as :default

  BULLETIN_LIST_URL = "https://www.apprenticeship.gov/about-us/legislation-regulations-guidance/bulletins/export?search=&category%5B0%5D=National%20Guideline%20Standards&category%5B1%5D=National%20Program%20Standards&category%5B2%5D=Occupations&page&_format=csv"

  def perform
    xlsx = Roo::Spreadsheet.open(BULLETIN_LIST_URL, extension: :csv)

    xlsx.parse(headers: true).each_with_index do |row, index|
      next if index < 1

      file_uri = row["File URI"]
      standards_import = StandardsImport.where(
        name: file_uri,
        organization: row["Title"]
      ).first_or_initialize(
        notes: "From Scraper::ApprenticeshipBulletinsJob",
        public_document: true,
        source_url: BULLETIN_LIST_URL,
        bulletin: true,
        metadata: { date: row["Date"] }
      )

      if standards_import.new_record?
        standards_import.save!

        if standards_import.files.attach(io: URI.parse(file_uri).open, filename: File.basename(file_uri))

          # SourceFile is created in background job so wait until it exists
          source_file = nil
          until source_file.present?
            source_file = standards_import.reload.files.last.source_file
          end

          source_file.update!(
            metadata: {
              date: row["Date"]
            },
            bulletin: true
          )
          if source_file.docx?
            Scraper::ExportFileAttachmentsJob.perform_later(source_file)
          end
        end
      end
    end
  end
end
