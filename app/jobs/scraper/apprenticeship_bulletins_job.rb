class Scraper::ApprenticeshipBulletinsJob < ApplicationJob
  queue_as :default

  BULLETIN_LIST_URL = "https://www.apprenticeship.gov/about-us/legislation-regulations-guidance/bulletins/export?search=&category%5B0%5D=National%20Guideline%20Standards&category%5B1%5D=National%20Program%20Standards&category%5B2%5D=Occupations&page&_format=csv"

  def perform
    xlsx = Roo::Spreadsheet.open(BULLETIN_LIST_URL, extension: :csv)

    xlsx.parse(headers: true).each_with_index do |row, index|
      next if index < 1

      CreateImportFromUri.call(
        uri: row["File URI"],
        title: row["Title"],
        notes: "From Scraper::ApprenticeshipBulletinsJob",
        source: Scraper::ApprenticeshipBulletinsJob::BULLETIN_LIST_URL,
        date: row["Date"],
        listing: true
      )
    end
  end
end
