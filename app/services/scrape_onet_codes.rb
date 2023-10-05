class ScrapeOnetCodes
  def call
    file = URI.open("https://www.onetonline.org/find/all/All_Occupations.csv?fmt=csv")
    CSV.parse(file, headers: true) do |row|
      onet = Onet.find_or_initialize_by(
        version: Onet::CURRENT_VERSION,
        code: row["Code"]
      )
      onet.update!(title: row["Occupation"])
      OnetWebService.new(onet).call
    end
  end
end
