require "elasticsearch"

enable_logging = ENV.fetch("ELASTIC_LOGGING_ENABLED", "false")
args = if Rails.env.production? && ENV["ELASTIC_CLOUD_ID"].present?
  {
    cloud_id: ENV.fetch("ELASTIC_CLOUD_ID"),
    user: ENV.fetch("ELASTIC_USER"),
    password: ENV.fetch("ELASTIC_PASSWORD"),
    log: ActiveModel::Type::Boolean.new.cast(enable_logging)
  }
else
  {log: ActiveModel::Type::Boolean.new.cast(enable_logging)}
end

Elasticsearch::Model.client = Elasticsearch::Client.new(args)
