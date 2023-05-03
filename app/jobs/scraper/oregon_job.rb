class Scraper::OregonJob < Scraper::WatirJob
  queue_as :default

  def perform
    base = "https://www.oregon.gov"
    apprenticeship_url = base + "/boli/apprenticeship/Pages/"

    browser = configure_watir_browser
    browser.goto(apprenticeship_url + "apprenticeship-opportunities.aspx")
    js_doc = browser.element(css: "tbody").wait_until(&:present?)
    body = Nokogiri::HTML(js_doc.inner_html)

    body.css("tr").each do |row|
      title = row.css("td").first.content

      browser.goto(apprenticeship_url + "trade-details.aspx?trade=" + title)
      next if browser.element(css: "div.alert.alert-warning").present?

      programs = browser.element(css: "tbody").wait_until(&:present?)
      programs_table = Nokogiri::HTML(programs.inner_html)

      programs_table.css("tr").each do |row|
        organization = row.css("td").first.content
        program_path = row.css("td > a").first["href"]

        browser.goto(base + program_path)
        next unless browser.element(css: "#primaryContent.col-md-12").present?

        standards = browser.element(css: "tbody").wait_until(&:present?)
        standards_table = Nokogiri::HTML(standards.inner_html)
        standards_table.css("tr").each do |row|
          file = row.css("td > a").first
          file_path = file["href"]
          file_name = file.content

          standards_import = StandardsImport.where(
            name: base + file_path,
            organization: organization
          ).first_or_initialize(
            notes: "From Scraper::OregonJob",
            public_document: true
          )

          if standards_import.new_record?
            standards_import.save!

            standards_import.files.attach(
              io: URI.open("https://www.oregon.gov#{file_path}"),
              filename: File.basename(file_name)
            )
          end
        end
      end
    end

    while browser.exists?
      browser.close
    end
  end
end
