require "elasticsearch"

args = if Rails.env.production?
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
