class OnetWebService
  attr_reader :onet, :base_url

  def initialize(onet)
    @onet = onet
    @base_url = "https://services.onetcenter.org/ws/online/occupations/#{onet.code}"
  end

  def call
    uri = URI.parse(base_url)
    request = Net::HTTP::Get.new(uri.request_uri)
    request["Accept"] = "application/json"
    request.basic_auth(ENV["ONET_WEB_SERVICES_USERNAME"], ENV["ONET_WEB_SERVICES_PASSWORD"])

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http|
      http.request(request)
    }

    data = JSON.parse(response.body)

    related_job_titles = data.dig("sample_of_reported_job_titles", "title")

    unless related_job_titles.nil?
      onet.update!(related_job_titles: related_job_titles)
    end
  end
end
