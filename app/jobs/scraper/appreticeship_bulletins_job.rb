class Scraper::AppreticeshipBulletinsJob < ApplicationJob
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
      ).first_or_create!(
        notes: "From Scraper::AppreticeshipBulletinsJob #{BULLETIN_LIST_URL}"
      )

      if standards_import.files.attach(io: URI.parse(file_uri).open, filename: File.basename(file_uri))
        file_import = standards_import.files.last.file_import
        file_import.update(
          metadata: {
            date: row["Date"]
          }
        )
      end
    end
  end
end
