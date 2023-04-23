class Scraper::WashingtonJob < Scraper::WatirJob
  queue_as :default

  def perform
    url_base = "https://secure.lni.wa.gov/arts-public/"

    browser = configure_watir_browser
    browser.goto(url_base + "#/program-search")
    js_doc = browser.element(css: "div.lni-u-flex.lni-u-flex-wrap.lni-u-items-end").wait_until(&:present?)
    js_doc.button(text: "Search").click

    next_button = browser.a(aria_label: "Next").wait_until(&:present?)
    program_ids = []

    loop do
      find_table = browser.element(css: "tbody").wait_until(&:present?)
      begin
        attempts ||= 0
        table = Nokogiri::HTML(find_table.inner_html)

        table.css("tr").each do |row|
          program_id = row.css("td.lni-u-text--center > a").first.content.strip
          program_ids << program_id
        end

        next_button.click!
        break if browser.a(aria_label: "Next", disabled: true).present?
      rescue Watir::Wait::TimeoutError => e
        attempts += 1
        if attempts <= 5
          sleep 60
          retry
        else
          Rails.error.report(e)
        end
      end
    end

    program_ids.uniq.each do |id|
      program_link = url_base + "#/program-details?programId=#{id}&from=%2Fprogram-search"
      browser.goto(program_link)
      browser.refresh
      file = browser.a(text: "Review the Program Standards").href
      file_path = file.gsub("https://", "")
      organization = browser.h3(class: "lni-u-heading--3").text

      begin
        standards_import = StandardsImport.where(
          name: file
        ).first_or_initialize(
          organization: organization,
          notes: "From Scraper::WashingtonJob: #{program_link}"
        )

        if standards_import.new_record?
          standards_import.save!

          standards_import.files.attach(
            io: URI.open("https://#{file_path}"),
            filename: File.basename(file)
          )
        end
      rescue OpenURI::HTTPError
        next
      rescue Watir::Exception::UnknownObjectException => e
        Rails.error.report(e, context: {program_id: id})
      end
    end
    browser.close
  end
end
