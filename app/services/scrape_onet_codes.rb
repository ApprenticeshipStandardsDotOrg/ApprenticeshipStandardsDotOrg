class ScrapeOnetCodes
  def call
    file = URI.open("https://www.onetonline.org/find/all/All_Occupations.csv?fmt=csv")
    CSV.parse(file, headers: true) do |row|
      formatted_code = format_code(row["Code"])
      onet = Onet.current_version.find_or_initialize_by(
        code: formatted_code
      )
      onet.update!(title: row["Occupation"])
      OnetWebService.new(onet).call
    end
  end

  def format_code(code)
    code.squish.sub(/^(\d{2})\./, '\1-')
  end
end
