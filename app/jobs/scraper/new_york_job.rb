class Scraper::NewYorkJob < ApplicationJob
  queue_as :default

  def perform
    protocol = "https://"
    url = "https://dol.ny.gov/apprenticeship/apprenticeship-trades"
    download_url_base = "dol.ny.gov/system/files/documents/2022/06"
    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)
    html = response.body
    doc = Nokogiri::HTML(html)

    table = doc.css("tbody")[0]
    table.css("tr").each do |row|
      next unless row.css("a").present?
      file_name = row.css("a").first["href"]
      file_path = if /https/.match?(file_name)
        file_name.gsub(/#{protocol}/, "").gsub(/#{download_url_base}/, "").gsub(".pdf", "")
      else
        file_name
      end

      begin
        CreateImportFromUri.call(
          uri: "https://#{download_url_base}#{file_path}.pdf",
          title: file_name,
          notes: "From Scraper::NewYorkJob",
          source: url
        )
      rescue OpenURI::HTTPError
        next
      end
    end
  end
end
