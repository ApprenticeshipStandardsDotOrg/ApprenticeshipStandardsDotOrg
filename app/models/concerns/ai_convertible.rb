module AIConvertible
  extend ActiveSupport::Concern

  included do
    def converted_with_ai?
      open_ai_import.present?
    end
  end
end
