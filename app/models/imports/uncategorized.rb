module Imports
  class Uncategorized < Import
    has_one_attached :file
    has_one :import, as: :parent, dependent: :destroy, autosave: true
  end
end
