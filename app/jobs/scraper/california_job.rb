class Scraper::CaliforniaJob < ApplicationJob
  queue_as :default

  def perform
    protocol = "https://"
    url_base = "www.dir.ca.gov/das/"
    fetch_url = protocol + url_base + "ProgramStandards.htm"

    uri = URI.parse(fetch_url)
    response = Net::HTTP.get_response(uri)
    html = response.body

    doc = Nokogiri::HTML(html)
    nodeset = doc.css(".main-primary a[href]")
    file_paths = nodeset.map { |element| element["href"] }.select { |href| href.ends_with?(".pdf") }

    file_paths.each do |path|
      query = url_base + path
      query.gsub!(/\s/, "%20")

      standards_import = StandardsImport.where(
        name: protocol + query,
        organization: fetch_url
      ).first_or_create!(
        notes: "From Scraper::CaliforniaJob"
      )

      # protocol needs to be hardcoded to avoid Rubocop error:
      # Security/Open: The use of `URI.open` is a serious security risk
      # https://github.com/rubocop/rubocop/issues/6216#issuecomment-1252449855
      standards_import.files.attach(io: URI.open("https://#{query}"), filename: File.basename(path))
    end
  end
end
