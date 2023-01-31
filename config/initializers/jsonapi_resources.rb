JSONAPI.configure do |config|
  # :underscored_key, :camelized_key, :dasherized_key, or custom
  config.json_key_format = :underscored_key

  # Allowed values are :integer(default), :uuid, :string, or a proc
  config.resource_key_type = :uuid
end
