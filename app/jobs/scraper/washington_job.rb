class Scraper::WashingtonJob < ApplicationJob
  queue_as :default

  def perform
    url_base = "https://secure.lni.wa.gov/arts-public/"
    browser = Watir::Browser.new
    browser.goto(url_base + "#/program-search")
    js_doc = browser.element(css: "div.lni-u-flex.lni-u-flex-wrap.lni-u-items-end").wait_until(&:present?)
    js_doc.button(text: "Search").click
    puts "clicked"

    find_table = browser.element(css: "tbody").wait_until(&:present?)
    table = Nokogiri::HTML(find_table.inner_html)
    table.css("tr").each do |row|
      organization = row.css("td.lni-u-text--left > a").first.content
      puts organization
      program_path = row.css("td.lni-u-text--center > a").first["href"]
      puts "*"*10

      # browser.goto(url_base + program_path)
      # find_file = browser.element(css: "div.lni-u-mv2 > ol > li")
      # file = Nokogiri::HTML(find_file.inner_html)
      # file_link = file.css("a").first["href"]

      # standards_import = StandardsImport.where(
      #   name: url_base + program_path,
      #   organization: organization
      # )
    end

    # Need to select rows per page and click 50
    # Click next button and iterate through all rows each time
    # Next page until button is disabled?
  end
end