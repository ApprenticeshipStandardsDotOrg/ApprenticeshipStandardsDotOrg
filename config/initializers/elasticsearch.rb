require "elasticsearch"
host = ENV.fetch("FOUNDELASTICSEARCH_URL", "http://localhost:9200")
Elasticsearch::Model.client = Elasticsearch::Client.new(host: host, log: false)
