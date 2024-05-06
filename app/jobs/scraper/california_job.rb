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
    file_paths = nodeset.map { |element| [element["href"], element.text.squish] }.select { |href, link_text| href.ends_with?(".pdf") }

    file_paths.each do |path, link_text|
      query = url_base + path
      query.gsub!(/\s/, "%20")

      CreateImportFromUri.call(
        uri: protocol + query,
        title: link_text,
        notes: "From Scraper::CaliforniaJob",
        source: fetch_url
      )
    end
  end
end
