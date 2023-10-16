require "elasticsearch"

host = ENV.fetch("FOUNDELASTICSEARCH_URL", "http://localhost:9200")

args = {
  host: host,
  log: false
}

if Rails.env.production?
  args.merge(
    port: "443",
    scheme: "https",
    user: ENV.fetch("ELASTICSEARCH_USER"),
    password: ENV.fetch("ELASTICSEARCH_PASSWORD")
  )
end

Elasticsearch::Model.client = Elasticsearch::Client.new(args)
