module Sanitizable
  extend ActiveSupport::Concern

  included do
    def fix_encoding(text)
      text.encode("UTF-8", "UTF-8", invalid: :replace, replace: "")
    end
  end
end
