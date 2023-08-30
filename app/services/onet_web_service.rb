class OnetWebService
  attr_reader :onet, :base_url

  def initialize(onet)
    @onet = onet
    @base_url = "https://services.onetcenter.org/ws/online/occupations/#{onet.code}"
  end

  def call
    uri = URI.parse(base_url)

    headers = {Authorization: "Bearer #{ENV.fetch("ONET_WEB_SERVICES_API_TOKEN")}"}
    response = Net::HTTP.get(uri, headers)
    data = JSON.parse(response)

    related_job_titles = data.dig("sample_of_reported_job_titles", "title")

    unless related_job_titles.nil?
      onet.update!(related_job_titles: related_job_titles)
    end
  end
end
