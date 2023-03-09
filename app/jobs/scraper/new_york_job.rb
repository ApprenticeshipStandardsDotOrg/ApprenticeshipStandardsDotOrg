class Scraper::NewYorkJob < ApplicationJob
  queue_as :default

  def perform
    url = "https://dol.ny.gov/apprenticeship/apprenticeship-trades"
    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)
    html = response.body
    doc = Nokogiri::HTML(html)

    table_and_nav = doc.css("div.wysiwyg--field-webny-wysiwyg-body")
    table = table_and_nav.css("tbody")[0]
    table.css("tr").each do |row|
      next unless row.css("a").present?
      file_name = row.css("a").first["href"]
      file_path = ""
      if file_name.match(/https/)
        file_path = file_name.gsub("https://dol.ny.gov/system/files/documents/2022/06", "").gsub(".pdf", "")
      else
        file_path = file_name
      end
      
      standards_import = StandardsImport.where(
        name: file_name,
      ).first_or_initialize(
        notes: "From Scraper::NewYorkJob: #{url}"
      )

      if standards_import.new_record?
        begin
          standards_import.files.attach(
            io: URI.open("https://www.dol.ny.gov/system/files/documents/2022/06#{file_path}.pdf"),
            filename: File.basename(file_name)
          )
          standards_import.save!
        rescue
          next
        end
      end
    end
  end
end