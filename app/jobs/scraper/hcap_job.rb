class Scraper::HcapJob < ApplicationJob
  queue_as :default

  def perform(offset = nil)
    base = ENV.fetch("AIRTABLE_BASE_ID", "appYV2tf9ynfAVQO5")
    table = ENV.fetch("AIRTABLE_TABLE_ID", "tblM9Bl9E4Fhddh7n")
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
      if pdf_uri.present?
        CreateImportFromUri.call(
          uri: pdf_uri,
          title: fields["Sponsor"],
          notes: "From Scraper::HcapJob",
          source: nil,
          metadata: fields
        )
      end
    end
  end
end
