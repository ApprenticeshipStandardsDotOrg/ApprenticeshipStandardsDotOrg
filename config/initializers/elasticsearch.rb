require "elasticsearch"

args = if Rails.env.production? && ENV["ELASTIC_CLOUD_ID"].present?
  {
    cloud_id: ENV.fetch("ELASTIC_CLOUD_ID"),
    user: ENV.fetch("ELASTIC_USER"),
    password: ENV.fetch("ELASTIC_PASSWORD"),
    log: false
  }
else
  {log: false}
end

Elasticsearch::Model.client = Elasticsearch::Client.new(args)
