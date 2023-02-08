require 'open-uri'
class Scraper::CaliforniaJob < ApplicationJob
  queue_as :default

  def perform
    url_base = "https://www.dir.ca.gov/das/"
    fetch_url =  url_base + "ProgramStandards.htm"
    uri = URI.parse(fetch_url)
    response = Net::HTTP.get_response(uri)
    html = response.body

    file_paths = html.scan(/="(.*\/.*.pdf)/).flatten

    if file_paths.any?
      standards_import = StandardsImport.create!(
        name: fetch_url,
        organization: "California",
        notes: "From scraper"
      )

      file_paths.each do |path|
        full_path = url_base + path
        full_path.gsub!(/\s/, "%20")
        standards_import.files.attach(io: URI.open(full_path), filename: File.basename(path))
      end
    end
  end
end
