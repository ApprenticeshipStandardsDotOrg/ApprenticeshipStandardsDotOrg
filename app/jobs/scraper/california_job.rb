class Scraper::CaliforniaJob < ApplicationJob
  queue_as :default

  def perform
    url_base = "https://www.dir.ca.gov/das/"
    fetch_url =  url_base + "ProgramStandards.htm"
    uri = URI.parse(fetch_url)
    response = Net::HTTP.get_response(uri)
    html = response.body

    file_paths = html.scan(/="(.*\/.*.pdf)/).flatten

    file_paths.each do |path|
      full_path = url_base + path
      full_path.gsub!(/\s/, "%20")

      standards_import = StandardsImport.where(
        name: full_path,
        organization: fetch_url,
      ).first_or_create!(
        notes: "From Scraper::CaliforniaJob"
      )

      standards_import.files.attach(io: URI.open(full_path), filename: File.basename(path))
    end
  end
end
