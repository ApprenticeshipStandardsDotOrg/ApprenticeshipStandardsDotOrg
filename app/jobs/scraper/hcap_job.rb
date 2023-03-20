class Scraper::HcapJob < ApplicationJob
  queue_as :default

  def perform(offset = nil)
    base = "appYV2tf9ynfAVQO5"
    table = "tblM9Bl9E4Fhddh7n"
    fetch_url = "https://api.airtable.com/v0/#{base}/#{table}"
    uri = URI.parse(fetch_url)

    headers = {Authorization: "Bearer #{ENV.fetch("AIRTABLE_PERSONAL_ACCESS_TOKEN")}"}
    params = {offset: offset}

    uri.query = URI.encode_www_form(params)
    response = Net::HTTP.get(uri, headers)
    data = JSON.parse(response)

    collect_files(data["records"])

    if data["offset"].present?
      perform(data["offset"])
    end
  end

  private

  def collect_files(records)
    records.each do |record|
      fields = record["fields"]

      pdf_uri = fields["PDF Download Resource"]
      standards_import = StandardsImport.where(
        name: pdf_uri,
        organization: fields["Sponsor"]
      ).first_or_initialize(
        notes: "From Scraper::HcapJob"
      )

      if standards_import.new_record?
        standards_import.save!

        if standards_import.files.attach(io: URI.parse(pdf_uri).open, filename: File.basename(pdf_uri))
          source_file = standards_import.files.last.source_file
          source_file.update!(
            metadata: fields
          )
        end
      end
    end
  end
end
