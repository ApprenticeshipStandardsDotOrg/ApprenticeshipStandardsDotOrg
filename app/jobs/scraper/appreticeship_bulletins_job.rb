class Scraper::AppreticeshipBulletinsJob < ApplicationJob
  queue_as :default

  BULLETIN_LIST_URL = "https://www.apprenticeship.gov/about-us/legislation-regulations-guidance/bulletins/export?search=&category%5B0%5D=National%20Guideline%20Standards&category%5B1%5D=National%20Program%20Standards&category%5B2%5D=Occupations&page&_format=csv"
  DOCX_CONTENT_TYPE = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"

  def perform
    xlsx = Roo::Spreadsheet.open(BULLETIN_LIST_URL, extension: :csv)

    xlsx.parse(headers: true).each_with_index do |row, index|
      next if index < 1

      file_uri = row["File URI"]
      file_name = CGI.unescape file_uri.split("/").last
      file = URI.parse(file_uri).open

      if docx_file?(file)
        docx = Docx::Document.open(file)

        if has_attachments?(docx)
          standards_import = StandardsImport.where(
            name: file_uri,
            organization: row["Title"]
          ).first_or_create!(
            notes: "From Scraper::AppreticeshipBulletinsJob #{BULLETIN_LIST_URL}"
          )

          standards_import.files.attach(io: URI.parse(file_uri).open, filename: File.basename(file_name))
        else
          Rails.logger.debug "File #{file_name} does not have attachments. Skipping"
        end
      else
        Rails.logger.debug "File with content type #{file.content_type} found. Skipping"
      end
    rescue OpenURI::HTTPError
      Rails.logger.debug "Error while trying to download #{file_name}"
    end
  end

  private

  def has_attachments?(docx)
    docx.paragraphs.none? { |p| p.to_s == "Attachments. None." }
  end

  def docx_file?(file)
    file&.content_type == DOCX_CONTENT_TYPE
  end
end
