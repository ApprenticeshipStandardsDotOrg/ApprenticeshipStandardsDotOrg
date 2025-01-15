module JsonImportable
  extend ActiveSupport::Concern

  class_methods do
    def from_open_ai_json(json, exclude_fields: [])
      resource = new(
        json.except(*exclude_fields).transform_keys(&:underscore)
      )
      yield(resource) if block_given?

      resource
    end
  end
end
