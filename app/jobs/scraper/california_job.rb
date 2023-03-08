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

      standards_import = StandardsImport.where(
        name: protocol + query,
        organization: link_text
      ).first_or_initialize(
        notes: "From Scraper::CaliforniaJob: #{fetch_url}"
      )

      if standards_import.new_record?
        standards_import.save!

        # protocol needs to be hardcoded to avoid Rubocop error:
        # Security/Open: The use of `URI.open` is a serious security risk
        # https://github.com/rubocop/rubocop/issues/6216#issuecomment-1252449855
        standards_import.files.attach(
          io: URI.open("https://#{query}"),
          filename: File.basename(path)
        )
      end
    end
  end
end
